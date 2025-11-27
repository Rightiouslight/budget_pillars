"use client";

import \* as React from "react";
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/AuthContext';
import { useSettings } from "@/context/SettingsContext";
import { useMonth } from "@/context/MonthContext";
import { useToast } from "@/hooks/use-toast";
import { getBudget, saveBudget, deleteAllBudgetsForUser, deleteBudget, shareBudget, getShareInvitations, manageShareInvitation, getSentShares, revokeShare } from "@/lib/firestore";
import type { Account, Category, Pocket, Transfer, Transaction, MonthlyBudget, RecurringIncome, ImportProfile, BudgetPermission, ShareInvitation, Card } from "@/lib/types";
import { format, subMonths, isAfter, startOfDay, parse, isValid, isSameDay } from "date-fns";
import { getRandomColor } from "@/lib/colors";
import type { DropResult } from '@hello-pangea/dnd';
import type { ParsedSmsData } from "@/components/budget/SmsImportDialog";
import { useTimeTravel } from "@/context/TimeTravelContext";
import { getDueDateForPeriod, extractSMSData } from "@/lib/utils";
import { EmailAuthProvider, linkWithCredential } from "firebase/auth";

const ACCOUNT_LIMIT = 5;
const CARDS_PER_ACCOUNT_LIMIT = 30;

const initialAccounts: Account[] = [
{
id: "acc_1",
name: "Main Bank",
icon: 'Landmark',
defaultPocketId: "pocket_1",
cards: [
{ type: 'pocket', id: "pocket_1", name: "Main Bank", balance: 1250.75, icon: 'Wallet', color: getRandomColor() },
{ type: 'pocket', id: "pocket_extra_1", name: "Savings", balance: 3000, icon: 'PiggyBank', color: getRandomColor() },
{ type: 'category', id: "cat_1", name: "Groceries", icon: 'ShoppingCart', budgetValue: 400, currentValue: 0, color: getRandomColor() },
{ type: 'category', id: "cat_2", name: "Rent", icon: 'Home', budgetValue: 1200, currentValue: 0, isRecurring: true, dueDate: 1, color: getRandomColor() },
{ type: 'category', id: "cat_3", name: "Transport", icon: 'Car', budgetValue: 150, currentValue: 0, color: getRandomColor() },
],
},
{
id: "acc_2",
name: "Credit Card",
icon: 'CreditCard',
defaultPocketId: "pocket_2",
cards: [
{ type: 'pocket', id: "pocket_2", name: "Credit Card", balance: 0, icon: 'Wallet', color: getRandomColor() },
{ type: 'category', id: "cat_4", name: "Entertainment", icon: 'Ticket', budgetValue: 100, currentValue: 0, color: getRandomColor() },
{ type: 'category', id: "cat_5", name: "Utilities", icon: 'Zap', budgetValue: 200, currentValue: 0, isRecurring: true, dueDate: 15, color: getRandomColor() },
],
},
];

type EditingCategory = { accountId: string; category: Category; };
type EditingPocket = { accountId: string; pocket: Pocket; };
type TransactionCandidate = { accountId: string; categoryId: string; categoryName: string; budgetValue: number; currentValue: number; };
type TransactionFilter = 'all' | { categoryId: string; categoryName: string } | { pocketId: string; pocketName: string, accountId: string } | { accountId: string; accountName: string };
type LinkPasswordData = { email: string; pass: string; };
type ViewingCardDetails = { card: Card, account: Account };
type PlannerCategory = { id: string; name: string; icon: string; accountId: string; originalValue: number; budgetValue: number; };

export function useBudgetManager() {
const { user, activeBudget, invitations, setInvitations, setActiveBudget, setOnLinkPassword } = useAuth();
const { isLoading: isLoadingSettings, currency, monthStartDate, importProfiles } = useSettings();
const { selectedMonth, setSelectedMonth, monthKey, displayMonth } = useMonth();
const { currentDate } = useTimeTravel();
const router = useRouter();
const { toast } = useToast();

    // Core State
    const [currentBudget, setCurrentBudget] = React.useState<MonthlyBudget | null>(null);
    const [isLoadingBudget, setIsLoadingBudget] = React.useState(true);

    // Interaction State
    const [transfer, setTransfer] = React.useState<Transfer | null>(null);
    const [transferSource, setTransferSource] = React.useState<Transfer['source'] | null>(null);
    const [reorderingAccountId, setReorderingAccountId] = React.useState<string | null>(null);
    const [isReorderingAccounts, setIsReorderingAccounts] = React.useState(false);
    const [isDragging, setIsDragging] = React.useState(false);
    const [startX, setStartX] = React.useState(0);
    const [scrollLeft, setScrollLeft] = React.useState(0);
    const fileInputRef = React.useRef<HTMLInputElement>(null);
    const [importingToAccountId, setImportingToAccountId] = React.useState<string | null>(null);
    const [sentShares, setSentShares] = React.useState<ShareInvitation[]>([]);
    const [isSharing, setIsSharing] = React.useState(false);

    // Dialog and Sheet State
    const [isAccountDialogOpen, setAccountDialogOpen] = React.useState(false);
    const [editingAccount, setEditingAccount] = React.useState<Account | null>(null);

    const [isCategoryDialogOpen, setCategoryDialogOpen] = React.useState(false);
    const [editingCategory, setEditingCategory] = React.useState<EditingCategory | null>(null);
    const [addingCategoryToAccount, setAddingCategoryToAccount] = React.useState<string | null>(null);

    const [isPocketDialogOpen, setPocketDialogOpen] = React.useState(false);
    const [editingPocket, setEditingPocket] = React.useState<EditingPocket | null>(null);
    const [addingPocketToAccount, setAddingPocketToAccount] = React.useState<string | null>(null);

    const [isTransactionDialogOpen, setTransactionDialogOpen] = React.useState(false);
    const [transactionCategory, setTransactionCategory] = React.useState<TransactionCandidate | null>(null);
    const [transactionPocket, setTransactionPocket] = React.useState<{ accountId: string; pocketId: string; pocketName:string; } | null>(null);
    const [editingTransaction, setEditingTransaction] = React.useState<Transaction | null>(null);
    const [parsedSmsData, setParsedSmsData] = React.useState<ParsedSmsData | null>(null);

    const [isIncomeDialogOpen, setIncomeDialogOpen] = React.useState(false);
    const [addingIncomeToAccount, setAddingIncomeToAccount] = React.useState<Account | null>(null);
    const [isRecurringIncomesDialogOpen, setRecurringIncomesDialogOpen] = React.useState(false);
    const [editingRecurringIncome, setEditingRecurringIncome] = React.useState<RecurringIncome | null>(null);
    const [viewingRecurringIncomesFor, setViewingRecurringIncomesFor] = React.useState<Account | null>(null);

    const [isTransactionsSheetOpen, setTransactionsSheetOpen] = React.useState(false);
    const [transactionsFilter, setTransactionsFilter] = React.useState<TransactionFilter>('all');

    const [isSettingsDialogOpen, setSettingsDialogOpen] = React.useState(false);
    const [isShareDialogOpen, setShareDialogOpen] = React.useState(false);
    const [isInvitationsDialogOpen, setInvitationsDialogOpen] = React.useState(false);
    const [isCardDetailsDialogOpen, setCardDetailsDialogOpen] = React.useState(false);
    const [viewingCardDetails, setViewingCardDetails] = React.useState<ViewingCardDetails | null>(null);
    const [isBudgetPlannerOpen, setBudgetPlannerOpen] = React.useState(false);
    const [planningForAccount, setPlanningForAccount] = React.useState<Account | null>(null);


    // Alert Dialogs
    const [deleteTransactionId, setDeleteTransactionId] = React.useState<string | null>(null);
    const [isImportDialogOpen, setImportDialogOpen] = React.useState(false);
    const [templateBudget, setTemplateBudget] = React.useState<MonthlyBudget | null>(null);
    const [linkPasswordData, setLinkPasswordData] = React.useState<LinkPasswordData | null>(null);

    const accounts = currentBudget?.accounts || [];
    const transactions = currentBudget?.transactions || [];
    const isLoading = isLoadingSettings || isLoadingBudget;

    // --- DATA FETCHING & MIGRATION ---

    const setBudgetWithChecks = React.useCallback((budgetData: MonthlyBudget | null) => {
        // This function can be expanded with more checks if new migrations are needed.
        setCurrentBudget(budgetData);
    }, []);

    React.useEffect(() => {
        if (!user || !activeBudget) {
            setBudgetWithChecks(null);
            setIsLoadingBudget(false);
            return;
        }

        const fetchBudget = async () => {
            setIsLoadingBudget(true);
            try {
                const budgetData = await getBudget(activeBudget.ownerUid, monthKey);
                setBudgetWithChecks(budgetData);
            } catch (error) {
                console.error("Error fetching budget:", error);
                toast({ title: "Error", description: "Could not load budget data.", variant: "destructive" });
            } finally {
                setIsLoadingBudget(false);
            }
        };

        if (!isLoadingSettings) {
            fetchBudget();
        }
    }, [user, monthKey, toast, isLoadingSettings, activeBudget, setBudgetWithChecks]);

    // --- AUTH LINKING HOOK ---
    React.useEffect(() => {
        setOnLinkPassword(() => (email, pass) => setLinkPasswordData({ email, pass }));
        return () => setOnLinkPassword(null);
    }, [setOnLinkPassword]);


    // --- HELPER FUNCTIONS ---

    const deepCopyBudget = (budget: MonthlyBudget): MonthlyBudget => {
        const jsonString = JSON.stringify(budget);
        const newBudget = JSON.parse(jsonString);
        if (newBudget.transactions) {
            newBudget.transactions.forEach((t: any) => {
                if (typeof t.date === 'string') {
                    t.date = new Date(t.date);
                }
            });
        }
        return newBudget;
    };

    const updateCurrentBudget = React.useCallback(async (updater: (budget: MonthlyBudget) => MonthlyBudget, alreadyCopied = false) => {
        if (!user || !currentBudget || !activeBudget) return;
        const budgetToUpdate = alreadyCopied ? currentBudget : deepCopyBudget(currentBudget);
        const updatedBudget = updater(budgetToUpdate);
        setCurrentBudget(updatedBudget);
        try {
            await saveBudget(activeBudget.ownerUid, monthKey, updatedBudget, activeBudget.permission);
        } catch (error) {
            console.error("Failed to save budget update", error);
            setCurrentBudget(currentBudget);
            toast({ title: "Save Error", description: "Could not save changes.", variant: "destructive" });
        }
    }, [user, currentBudget, activeBudget, monthKey, toast]);

    const handleQuickTransaction = React.useCallback((accountId: string, categoryId: string, isAuto: boolean = false) => {
        updateCurrentBudget(budget => {
            const account = budget.accounts.find(a => a.id === accountId);
            const category = account?.cards?.find(c => c.id === categoryId && c.type === 'category') as Category | undefined;

            if (!account || !category || !category.isRecurring) return budget;

            const amount = category.budgetValue - category.currentValue;
            if (amount <= 0) {
                if (!isAuto) toast({ title: "Nothing to Pay", variant: "destructive" });
                return budget;
            }

            const sourcePocket = account.cards.find(p => p.id === account.defaultPocketId && p.type === 'pocket') as Pocket | undefined;
            if (!sourcePocket) return budget;

            if (category.destinationPocketId) {
                if (!category.destinationAccountId) {
                    toast({
                        title: "Invalid Linked Pocket",
                        description: `The configuration for "${category.name}" is incomplete. Please edit the category and re-select the destination pocket.`,
                        variant: "destructive",
                        duration: 8000,
                    });
                    return budget;
                }

                const destAccount = budget.accounts.find(a => a.id === category.destinationAccountId);
                const destPocket = destAccount?.cards?.find(p => p.id === category.destinationPocketId && c.type === 'pocket') as Pocket | undefined;

                if (destAccount && destPocket) {
                    category.currentValue += amount;
                    sourcePocket.balance -= amount;
                    const newTransaction: Transaction = {
                        id: `txn_${Date.now()}`,
                        amount,
                        description: `Auto-transfer for ${category.name}`,
                        date: new Date(),
                        accountId: account.id,
                        accountName: account.name,
                        categoryId: sourcePocket.id,
                        categoryName: `Transfer: ${sourcePocket.name} -> ${destPocket.name}`,
                        targetAccountId: destAccount.id,
                        targetAccountName: destAccount.name,
                        targetPocketId: destPocket.id,
                        targetPocketName: destPocket.name,
                        sourceType: 'pocket'
                    };
                    budget.transactions.unshift(newTransaction);
                }
            } else {
                // This is a normal quick payment
                category.currentValue += amount;
                sourcePocket.balance -= amount;
                const newTransaction: Transaction = { id: `txn_${Date.now()}`, amount, description: `Payment for ${category.name}`, date: new Date(), accountId, categoryId, accountName: account.name, categoryName: category.name, sourcePocketId: sourcePocket.id };
                budget.transactions.unshift(newTransaction);
            }

            if (!budget.autoTransactionsProcessed) budget.autoTransactionsProcessed = {};
            budget.autoTransactionsProcessed[categoryId] = true;

            if (!isAuto) toast({ title: category.destinationPocketId ? "Transfer Successful" : "Payment Successful" });
            return budget;
        });
    }, [updateCurrentBudget, toast]);

    // --- AUTOMATIC PROCESSING HOOKS ---
    React.useEffect(() => {
        if (!currentBudget || !user || !monthStartDate || !activeBudget || activeBudget.permission !== 'write' || isLoading) return;

        const transactionsToProcess = {
            expenses: [] as { accountId: string, categoryId: string }[],
            incomes: [] as { incomeId: string }[],
        };

        const today = startOfDay(currentDate);

        // --- Collect due recurring expenses ---
        currentBudget.accounts.forEach(account => {
            (account.cards || []).forEach(card => {
                if (
                    card.type === 'category' &&
                    card.isRecurring &&
                    card.dueDate && card.dueDate !== 99 &&
                    !currentBudget.autoTransactionsProcessed?.[card.id] &&
                    (card.budgetValue - card.currentValue > 0)
                ) {
                    const dueDateForPeriod = getDueDateForPeriod(card.dueDate, displayMonth, monthStartDate);
                    if (isAfter(today, dueDateForPeriod) || today.getTime() === startOfDay(dueDateForPeriod).getTime()) {
                        transactionsToProcess.expenses.push({ accountId: account.id, categoryId: card.id });
                    }
                }
            });
        });

        // --- Collect due recurring incomes ---
        (currentBudget.recurringIncomes || []).forEach(income => {
            if (income.dayOfMonth && !currentBudget.processedRecurringIncomes?.[income.id]) {
                if (income.dayOfMonth !== 99) {
                    const depositDateForPeriod = getDueDateForPeriod(income.dayOfMonth, displayMonth, monthStartDate);
                    if (isAfter(today, depositDateForPeriod) || today.getTime() === startOfDay(depositDateForPeriod).getTime()) {
                        transactionsToProcess.incomes.push({ incomeId: income.id });
                    }
                }
            }
        });

        if (transactionsToProcess.expenses.length > 0 || transactionsToProcess.incomes.length > 0) {
             updateCurrentBudget(budget => {
                const updatedBudget = deepCopyBudget(budget);
                if (!updatedBudget.autoTransactionsProcessed) updatedBudget.autoTransactionsProcessed = {};
                if (!updatedBudget.processedRecurringIncomes) updatedBudget.processedRecurringIncomes = {};

                transactionsToProcess.expenses.forEach(({ accountId, categoryId }) => {
                    const account = updatedBudget.accounts.find(a => a.id === accountId);
                    const category = account?.cards?.find(c => c.id === categoryId && c.type === 'category') as Category | undefined;
                    const sourcePocket = account?.cards.find(p => p.id === account.defaultPocketId && p.type === 'pocket') as Pocket | undefined;

                    if (account && category && sourcePocket) {
                        const amount = category.budgetValue - category.currentValue;
                        if (amount > 0) {
                            if (category.destinationPocketId && category.destinationAccountId) {
                                const destAccount = updatedBudget.accounts.find(a => a.id === category.destinationAccountId);
                                const destPocket = destAccount?.cards?.find(p => p.id === category.destinationPocketId && c.type === 'pocket') as Pocket | undefined;
                                if (destAccount && destPocket) {
                                    category.currentValue += amount;
                                    sourcePocket.balance -= amount;
                                    updatedBudget.transactions.unshift({
                                        id: `txn_${Date.now()}_${Math.random()}`, amount, description: `Auto-transfer for ${category.name}`, date: new Date(),
                                        accountId: account.id, accountName: account.name, categoryId: sourcePocket.id,
                                        categoryName: `Transfer: ${sourcePocket.name} -> ${destPocket.name}`,
                                        targetAccountId: destAccount.id, targetAccountName: destAccount.name, targetPocketId: destPocket.id,
                                        targetPocketName: destPocket.name, sourceType: 'pocket'
                                    });
                                }
                            } else {
                                category.currentValue += amount;
                                sourcePocket.balance -= amount;
                                updatedBudget.transactions.unshift({
                                    id: `txn_${Date.now()}_${Math.random()}`, amount, description: `Payment for ${category.name}`, date: new Date(),
                                    accountId: account.id, categoryId: category.id, accountName: account.name,
                                    categoryName: category.name, sourcePocketId: sourcePocket.id
                                });
                            }
                            updatedBudget.autoTransactionsProcessed![categoryId] = true;
                        }
                    }
                });

                transactionsToProcess.incomes.forEach(({ incomeId }) => {
                    const income = updatedBudget.recurringIncomes?.find(i => i.id === incomeId);
                    if (income) {
                        const account = updatedBudget.accounts.find(a => a.id === income.accountId);
                        const pocket = account?.cards?.find(c => c.id === income.pocketId && c.type === 'pocket') as Pocket | undefined;
                        if (account && pocket) {
                            pocket.balance += income.amount;
                            updatedBudget.transactions.unshift({
                                id: `txn_${Date.now()}_${Math.random()}`, amount: income.amount,
                                description: income.description || 'Recurring Income', date: new Date(),
                                accountId: account.id, accountName: account.name, categoryId: pocket.id,
                                categoryName: `Income to ${pocket.name}`, recurringIncomeId: income.id,
                            });
                             updatedBudget.processedRecurringIncomes![incomeId] = true;
                        }
                    }
                });
                return updatedBudget;
             });

            if (transactionsToProcess.expenses.length > 0) {
                toast({ title: "Automatic Payments Processed", description: `${transactionsToProcess.expenses.length} recurring expense(s) were automatically paid.` });
            }
            if (transactionsToProcess.incomes.length > 0) {
                toast({ title: "Recurring Incomes Deposited", description: `${transactionsToProcess.incomes.length} income(s) have been added to your pockets.` });
            }
        }
    }, [currentBudget, user, monthStartDate, activeBudget, isLoading, currentDate, displayMonth, toast, updateCurrentBudget]);


    // --- HANDLERS ---

    const handleImportBudget = async () => {
        if (!user || !activeBudget) return;
        const previousMonthKey = format(subMonths(displayMonth, 1), "yyyy-MM");
        setIsLoadingBudget(true);
        try {
            const budget = await getBudget(activeBudget.ownerUid, previousMonthKey);
            if (!budget) {
                toast({ title: "No Previous Budget Found", description: "Cannot import because no budget exists for the prior month.", variant: "destructive" });
                setIsLoadingBudget(false);
                return;
            }
            setTemplateBudget(budget);
            setImportDialogOpen(true);
        } catch (error) {
            console.error("Error fetching previous budget:", error);
            toast({ title: "Error", description: "Failed to fetch previous budget.", variant: "destructive" });
            setIsLoadingBudget(false);
        }
    };

    const executeImport = async (includeBalances: boolean) => {
        if (!user || !templateBudget || !activeBudget) return;
        setImportDialogOpen(false);
        try {
            const newAccounts = templateBudget.accounts.map(account => {
                const newCards = (account.cards || []).map(card => {
                    const newCard = { ...card, color: card.color || getRandomColor() };
                    if (newCard.type === 'pocket') {
                        return { ...newCard, balance: includeBalances ? newCard.balance : 0 };
                    } else if (newCard.type === 'category') {
                        return { ...newCard, currentValue: 0 };
                    }
                    return newCard;
                });
                return { ...account, cards: newCards };
            });

            const newTransactions: Transaction[] = [];
            const processedIncomes: { [incomeId: string]: boolean } = {};

            if (templateBudget.recurringIncomes) {
                templateBudget.recurringIncomes.forEach(rec_inc => {
                    if (rec_inc.dayOfMonth === 99) {
                        const account = newAccounts.find(a => a.id === rec_inc.accountId);
                        if (account) {
                            const pocketCard = account.cards.find(c => c.id === rec_inc.pocketId && c.type === 'pocket') as Pocket | undefined;
                            if (pocketCard) {
                                pocketCard.balance += rec_inc.amount;
                                newTransactions.push({
                                    id: `txn_${Date.now()}_${Math.random()}`,
                                    amount: rec_inc.amount,
                                    description: rec_inc.description,
                                    date: new Date(),
                                    accountId: account.id,
                                    accountName: account.name,
                                    categoryId: pocketCard.id,
                                    categoryName: `Income to ${pocketCard.name}`,
                                    recurringIncomeId: rec_inc.id,
                                });
                                processedIncomes[rec_inc.id] = true;
                            }
                        }
                    }
                });
            }

            const newBudget: MonthlyBudget = {
                accounts: newAccounts,
                transactions: newTransactions,
                recurringIncomes: templateBudget.recurringIncomes || [],
                autoTransactionsProcessed: {},
                processedRecurringIncomes: processedIncomes,
            };

            await saveBudget(activeBudget.ownerUid, monthKey, newBudget, activeBudget.permission);
            setCurrentBudget(newBudget);
            toast({ title: "Budget Imported", description: `Your budget from ${format(subMonths(displayMonth, 1), "MMMM")} has been set up.`});
        } catch (error) {
            console.error("Error importing budget:", error);
            toast({ title: "Error", description: "Failed to import budget.", variant: "destructive" });
        } finally {
            setIsLoadingBudget(false);
            setTemplateBudget(null);
        }
    };

    const handleResetCategories = async () => {
        if (!user || !currentBudget || !activeBudget) return;
        const previousMonthKey = format(subMonths(displayMonth, 1), "yyyy-MM");
        try {
            const templateBudget = await getBudget(activeBudget.ownerUid, previousMonthKey);
            if (!templateBudget) {
                toast({ title: "No Previous Budget", variant: "destructive" });
                return;
            }
            const newAccounts = templateBudget.accounts.map(templateAccount => {
                const currentAccount = currentBudget.accounts.find(a => a.id === templateAccount.id);
                const newCards = (templateAccount.cards || []).map(card => {
                    if (card.type === 'pocket') {
                        const currentPocket = currentAccount?.cards?.find(c => c.id === card.id && c.type === 'pocket') as Pocket | undefined;
                        return { ...card, balance: currentPocket ? currentPocket.balance : card.balance, icon: currentPocket?.icon || card.icon || 'PiggyBank', color: currentPocket?.color || card.color || getRandomColor() };
                    }
                    return { ...card, currentValue: 0, color: card.color || getRandomColor() };
                });
                return { ...templateAccount, cards: newCards };
            });
            currentBudget.transactions.forEach(tx => {
                if (tx.categoryName.startsWith("Transfer:") || tx.categoryName.startsWith("Income to") || tx.categoryName.startsWith("Expense:")) return;
                const account = newAccounts.find(a => a.id === tx.accountId);
                const category = account?.cards?.find(c => c.id === tx.categoryId && c.type === 'category') as Category | undefined;
                if (category) category.currentValue += tx.amount;
            });
            const updatedBudget: MonthlyBudget = { ...currentBudget, accounts: newAccounts, autoTransactionsProcessed: {}, processedRecurringIncomes: {} };
            await saveBudget(activeBudget.ownerUid, monthKey, updatedBudget, activeBudget.permission);
            setCurrentBudget(updatedBudget);
            toast({ title: "Categories Reset" });
        } catch (error) {
            console.error("Error resetting categories:", error);
            toast({ title: "Error", description: "Failed to reset categories.", variant: "destructive" });
        }
    };

    const handleStartFromScratch = async () => {
        if (!user || !activeBudget) return;
        const newBudget: MonthlyBudget = { accounts: [], transactions: [], recurringIncomes: [], autoTransactionsProcessed: {}, processedRecurringIncomes: {} };
        await saveBudget(activeBudget.ownerUid, monthKey, newBudget, activeBudget.permission);
        setCurrentBudget(newBudget);
        toast({ title: "Fresh Start!" });
    };

    const handleStartWithDemo = async () => {
        if (!user || !activeBudget) return;
        const demoBudget: MonthlyBudget = { accounts: initialAccounts, transactions: [], recurringIncomes: [], autoTransactionsProcessed: {}, processedRecurringIncomes: {} };
        await saveBudget(activeBudget.ownerUid, monthKey, demoBudget, activeBudget.permission);
        setCurrentBudget(demoBudget);
        toast({ title: "Demo Budget Created!" });
    };

    const handleResetData = async () => {
        if (!user) return;
        try {
            await deleteAllBudgetsForUser(user.uid);
            const newMonthKey = format(new Date(), "yyyy-MM");
            const demoBudget: MonthlyBudget = { accounts: initialAccounts, transactions: [], recurringIncomes: [], autoTransactionsProcessed: {}, processedRecurringIncomes: {} };
            await saveBudget(user.uid, newMonthKey, demoBudget);
            if (newMonthKey === monthKey) setCurrentBudget(demoBudget);
            else setSelectedMonth(new Date());
            toast({ title: "Data Reset" });
        } catch (error) {
            console.error("Error resetting data:", error);
            toast({ title: "Error", variant: "destructive" });
        }
    };

    const handleDeleteCurrentMonth = async () => {
        if (!user || !currentBudget || !activeBudget) return;
        try {
            await deleteBudget(activeBudget.ownerUid, monthKey);
            setCurrentBudget(null);
            toast({ title: "Month Reset" });
        } catch (error) {
            console.error("Error deleting current month's budget:", error);
            toast({ title: "Error", variant: "destructive" });
        }
    };

    const initiateTransfer = (source: Transfer['source']) => {
        if (transferSource?.itemId === source.itemId) setTransferSource(null);
        else setTransferSource(source);
    };

    const selectTransferTarget = (target: Omit<Transfer['target'], 'type' | 'icon'>) => {
        if (!transferSource || transferSource.itemId === target.itemId) {
            setTransferSource(null);
            return;
        }
        setTransfer({ source: transferSource, target: { ...target, type: 'pocket', icon: 'PiggyBank' } });
        setTransferSource(null);
    };

    const cancelTransfer = () => setTransferSource(null);

    const handleTransferSubmit = (amount: number, description: string) => {
        if (!transfer) return;
        updateCurrentBudget(budget => {
            const accountForSource = budget.accounts.find(a => a.id === transfer.source.accountId);
            const accountForTarget = budget.accounts.find(a => a.id === transfer.target.accountId);
            if (!accountForSource || !accountForTarget || !accountForSource.cards || !accountForTarget.cards) return budget;

            const sourceCard = accountForSource.cards.find(c => c.id === transfer.source.itemId);
            if (sourceCard?.type === 'pocket') (sourceCard as Pocket).balance -= amount;
            else if (sourceCard?.type === 'category') (sourceCard as Category).currentValue -= amount;

            const targetPocket = accountForTarget.cards.find(c => c.id === transfer.target.itemId && c.type === 'pocket') as Pocket | undefined;
            if (targetPocket) targetPocket.balance += amount;

            budget.transactions.unshift({
                id: `txn_${Date.now()}`, amount, description: description || `Transfer`, date: new Date(),
                accountId: transfer.source.accountId, accountName: accountForSource.name, categoryId: transfer.source.itemId,
                categoryName: `Transfer: ${transfer.source.name} -> ${transfer.target.name}`,
                targetAccountId: transfer.target.accountId,
                targetAccountName: accountForTarget.name, targetPocketId: transfer.target.itemId, targetPocketName: targetPocket.name,
                sourceType: transfer.source.type,
                sourcePocketId: transfer.source.type === 'pocket' ? transfer.source.itemId : accountForSource.defaultPocketId,
            });
            return budget;
        });
        toast({ title: "Transfer Successful" });
        setTransfer(null);
    };

    const handleDeleteAccount = (accountId: string) => {
        updateCurrentBudget(budget => ({ ...budget, accounts: budget.accounts.filter(a => a.id !== accountId) }));
        toast({ title: "Account Deleted" });
    };

    const handleSaveAccount = (data: { name: string, icon: string }) => {
        updateCurrentBudget(budget => {
            if (editingAccount) {
                const acc = budget.accounts.find(acc => acc.id === editingAccount.id);
                if (acc) { acc.name = data.name; acc.icon = data.icon; }
            } else {
                const newPocketId = `pocket_${Date.now()}`;
                budget.accounts.push({
                    id: `acc_${Date.now()}`, name: data.name, icon: data.icon, defaultPocketId: newPocketId,
                    cards: [{ type: 'pocket', id: newPocketId, name: data.name, balance: 0, icon: 'Wallet', color: getRandomColor() }],
                });
            }
            return budget;
        });
        toast({ title: editingAccount ? "Account Updated" : "Account Added" });
        setAccountDialogOpen(false);
    };

    const handleDeleteCategory = (accountId: string, categoryId: string) => {
        updateCurrentBudget(budget => {
            const account = budget.accounts.find(acc => acc.id === accountId);
            if (account?.cards) account.cards = account.cards.filter(c => c.id !== categoryId);
            return budget;
        });
        toast({ title: "Category Deleted" });
    };

    const handleSaveCategory = (data: Omit<Category, 'id' | 'currentValue' | 'type'>) => {
        updateCurrentBudget(budget => {
            const accountToUpdate = editingCategory ? budget.accounts.find(acc => acc.id === editingCategory.accountId) : budget.accounts.find(acc => acc.id === addingCategoryToAccount);
            if (!accountToUpdate?.cards) return budget;

            const categoryData: Partial<Category> = { ...data };

            Object.keys(categoryData).forEach(key => {
                const typedKey = key as keyof typeof categoryData;
                if (categoryData[typedKey] === undefined) {
                    delete categoryData[typedKey];
                }
            });

            if (editingCategory) {
                const categoryIndex = accountToUpdate.cards.findIndex(c => c.id === editingCategory.category.id);
                if (categoryIndex > -1) {
                    const existingCategory = accountToUpdate.cards[categoryIndex];
                    accountToUpdate.cards[categoryIndex] = { ...existingCategory, ...categoryData };
                }
            } else {
                accountToUpdate.cards.push({ type: 'category', id: `cat_${Date.now()}`, ...categoryData, currentValue: 0 } as Category);
            }
            return budget;
        });
        toast({ title: editingCategory ? "Category Updated" : "Category Added" });
        setCategoryDialogOpen(false);
        setEditingCategory(null);
        setAddingCategoryToAccount(null);
    };

    const handleDeletePocket = (accountId: string, pocketId: string) => {
        updateCurrentBudget(budget => {
            const account = budget.accounts.find(acc => acc.id === accountId);
            if (account?.cards) {
                if (account.cards.filter(c => c.type === 'pocket').length <= 1) {
                    toast({ title: "Cannot Delete", variant: "destructive" });
                } else if (account.defaultPocketId === pocketId) {
                    toast({ title: "Cannot Delete Default Pocket", variant: "destructive" });
                } else {
                    account.cards = account.cards.filter(p => p.id !== pocketId);
                    toast({ title: "Pocket Deleted" });
                }
            }
            return budget;
        });
    };

    const handleSavePocket = (data: { name: string; balance: number; icon: string; color: string; }) => {
        updateCurrentBudget(budget => {
            const accountToUpdate = editingPocket ? budget.accounts.find(acc => acc.id === editingPocket.accountId) : budget.accounts.find(acc => acc.id === addingPocketToAccount);
            if (!accountToUpdate?.cards) return budget;

            if (editingPocket) {
                const pocketIndex = accountToUpdate.cards.findIndex(c => c.id === editingPocket.pocket.id);
                if (pocketIndex > -1) accountToUpdate.cards[pocketIndex] = { ...accountToUpdate.cards[pocketIndex], ...data };
            } else {
                accountToUpdate.cards.push({ type: 'pocket', id: `pocket_${Date.now()}`, ...data, balance: 0 });
            }
            return budget;
        });
        toast({ title: editingPocket ? "Pocket Updated" : "Pocket Added" });
        setPocketDialogOpen(false);
        setEditingPocket(null);
        setAddingPocketToAccount(null);
    };

    const handleSmsParse = (data: ParsedSmsData) => {
        setParsedSmsData(data);
    };

    const handleSaveTransaction = (amount: number, description: string, date: Date) => {
        if (editingTransaction) {
            updateCurrentBudget(budget => {
                const originalTx = budget.transactions.find(t => t.id === editingTransaction.id);
                if (!originalTx) return budget;
                const amountDifference = amount - originalTx.amount;
                const account = budget.accounts.find(a => a.id === originalTx.accountId);
                if (account?.cards) {
                    const category = account.cards.find(c => c.id === originalTx.categoryId && c.type === 'category') as Category | undefined;
                    if (category) category.currentValue += amountDifference;
                    const defaultPocket = account.cards.find(p => p.id === account.defaultPocketId && p.type === 'pocket') as Pocket | undefined;
                    if (defaultPocket) defaultPocket.balance -= amountDifference;
                }
                originalTx.amount = amount;
                originalTx.description = description;
                originalTx.date = date;
                return budget;
            });
            toast({ title: "Transaction Updated" });
        } else if (transactionCategory) {
                const { accountId, categoryId, categoryName } = transactionCategory;
                updateCurrentBudget(budget => {
                    const account = budget.accounts.find(a => a.id === accountId);
                    if (!account?.cards) return budget;
                    const category = account.cards.find(c => c.id === categoryId && c.type === 'category') as Category | undefined;
                    if (category) category.currentValue += amount;
                    const defaultPocket = account.cards.find(p => p.id === account.defaultPocketId && p.type === 'pocket') as Pocket | undefined;
                    if (defaultPocket) defaultPocket.balance -= amount;
                    budget.transactions.unshift({ id: `txn_${Date.now()}`, amount, description: description || `Expense`, date, accountId, categoryId, accountName: account.name, categoryName: categoryName, sourcePocketId: defaultPocket?.id });
                    return budget;
                });
                toast({ title: "Transaction Added" });
        } else if (transactionPocket) {
            const { accountId, pocketId, pocketName } = transactionPocket;
            updateCurrentBudget(budget => {
                const account = budget.accounts.find(a => a.id === accountId);
                if (!account?.cards) return budget;
                const pocket = account.cards.find(p => p.id === pocketId && p.type === 'pocket') as Pocket | undefined;
                if (pocket) pocket.balance -= amount;
                budget.transactions.unshift({ id: `txn_${Date.now()}`, amount, description: description || `Expense`, date, accountId, accountName: account.name, categoryId: pocketId, categoryName: `Expense: ${pocketName}`, sourcePocketId: pocketId });
                return budget;
            });
            toast({ title: "Expense Added" });
        }
        setTransactionDialogOpen(false);
        setEditingTransaction(null);
        setTransactionCategory(null);
        setTransactionPocket(null);
        setParsedSmsData(null);
    };

    const handleDeleteTransaction = (transactionId: string) => {
        const txToDelete = transactions.find(t => t.id === transactionId);
        if (!txToDelete) return;
        updateCurrentBudget(budget => {
            const txIndex = budget.transactions.findIndex(t => t.id === transactionId);
            if (txIndex === -1) return budget;
            const { amount, accountId, categoryId, categoryName, targetAccountId, targetPocketId, sourceType, recurringIncomeId, sourcePocketId } = budget.transactions[txIndex];
            if (categoryName.startsWith('Transfer:') && targetAccountId && targetPocketId) {
                const sourceAccount = budget.accounts.find(a => a.id === accountId);
                const targetAccount = budget.accounts.find(a => a.id === targetAccountId);
                if (sourceAccount?.cards && targetAccount?.cards) {
                    if(sourceType === 'pocket'){
                         const sourcePocket = sourceAccount.cards.find(c => c.id === sourcePocketId && c.type === 'pocket') as Pocket | undefined;
                         if (sourcePocket) sourcePocket.balance += amount;
                    } else {
                        const sourceCard = sourceAccount.cards.find(c => c.id === categoryId) as Category | undefined;
                        if (sourceCard) sourceCard.currentValue += amount;
                    }
                    const targetPocket = targetAccount.cards.find(c => c.id === targetPocketId && c.type === 'pocket') as Pocket | undefined;
                    if (targetPocket) targetPocket.balance -= amount;
                }
            } else if (categoryName.startsWith('Income to')) {
                const account = budget.accounts.find(a => a.id === accountId);
                const pocket = account?.cards?.find(c => c.id === categoryId && c.type === 'pocket') as Pocket | undefined;
                if (pocket) pocket.balance -= amount;
                if (recurringIncomeId && budget.recurringIncomes) {
                    const recIndex = budget.recurringIncomes.findIndex(ri => ri.id === recurringIncomeId);
                    if (recIndex > -1) {
                         budget.recurringIncomes.splice(recIndex, 1);
                    }
                }
            } else if (categoryName.startsWith('Expense:')) {
                const account = budget.accounts.find(a => a.id === accountId);
                const pocket = account?.cards?.find(c => c.id === categoryId && c.type === 'pocket') as Pocket | undefined;
                if (pocket) pocket.balance += amount;
            } else {
                const account = budget.accounts.find(a => a.id === accountId);
                if (account?.cards) {
                    const category = account.cards.find(c => c.id === categoryId && c.type === 'category') as Category | undefined;
                    if (category) category.currentValue -= amount;
                    const defaultPocket = account.cards.find(p => p.id === account.defaultPocketId && p.type === 'pocket') as Pocket | undefined;
                    if (defaultPocket) defaultPocket.balance += amount;
                }
            }
            budget.transactions.splice(txIndex, 1);
            return budget;
        });
        toast({ title: txToDelete.recurringIncomeId ? "Recurring Income Deleted" : "Transaction Deleted" });
    };

    const handleAddIncome = (data: { amount: number, description: string, pocketId: string, isRecurring: boolean, date: Date, dayOfMonth?: number }) => {
        if (!addingIncomeToAccount) return;

        updateCurrentBudget(budget => {
            const account = budget.accounts.find(a => a.id === addingIncomeToAccount.id);
            if (!account?.cards) return budget;
            const pocket = account.cards.find(p => p.id === data.pocketId && c.type === 'pocket') as Pocket | undefined;
            if (!pocket) return budget;

            pocket.balance += data.amount;
            const newTransaction: Transaction = {
                id: `txn_${Date.now()}`,
                amount: data.amount,
                description: data.description || 'Income',
                date: data.date,
                accountId: account.id,
                accountName: account.name,
                categoryId: data.pocketId,
                categoryName: `Income to ${pocket.name}`,
                sourcePocketId: pocket.id,
            };
            budget.transactions.unshift(newTransaction);
            return budget;
        });

        toast({ title: "Income Added" });
        setIncomeDialogOpen(false);
        setAddingIncomeToAccount(null);
        setParsedSmsData(null);
    };

    const handleSaveRecurringIncome = (data: RecurringIncome) => {
        const isNew = !currentBudget?.recurringIncomes?.some(ri => ri.id === data.id);

        updateCurrentBudget(budget => {
            if (!budget.recurringIncomes) {
                budget.recurringIncomes = [];
            }

            if (isNew) {
                budget.recurringIncomes.push(data);
            } else {
                const index = budget.recurringIncomes.findIndex(ri => ri.id === data.id);
                if (index > -1) {
                    budget.recurringIncomes[index] = data;
                }
            }

            if (isNew && data.dayOfMonth === 99) {
                const account = budget.accounts.find(a => a.id === data.accountId);
                if (account) {
                    const pocket = account.cards?.find(c => c.id === data.pocketId && c.type === 'pocket') as Pocket | undefined;
                    if (pocket) {
                        pocket.balance += data.amount;
                        const newTransaction: Transaction = {
                            id: `txn_${Date.now()}_immediate`,
                            amount: data.amount,
                            description: data.description,
                            date: new Date(),
                            accountId: account.id,
                            accountName: account.name,
                            categoryId: pocket.id,
                            categoryName: `Income to ${pocket.name}`,
                            recurringIncomeId: data.id,
                            sourcePocketId: pocket.id,
                        };
                        budget.transactions.unshift(newTransaction);

                        if (!budget.processedRecurringIncomes) {
                            budget.processedRecurringIncomes = {};
                        }
                        budget.processedRecurringIncomes[data.id] = true;

                    }
                }
            }
            return budget;
        });

        toast({ title: isNew ? "Recurring Income Added" : "Recurring Income Updated" });
        setIncomeDialogOpen(false);
        setEditingRecurringIncome(null);
        setAddingIncomeToAccount(null);
    };

    const handleDeleteRecurringIncome = (incomeId: string) => {
        updateCurrentBudget(budget => {
            if (budget.recurringIncomes) {
                budget.recurringIncomes = budget.recurringIncomes.filter(ri => ri.id !== incomeId);
            }
            return budget;
        });
        toast({ title: "Recurring Income Deleted" });
    };

    const handleBudgetPlannerSubmit = (changedCategories: PlannerCategory[]) => {
      updateCurrentBudget(budget => {
        changedCategories.forEach(changedCat => {
          const account = budget.accounts.find(acc => acc.id === changedCat.accountId);
          if (account?.cards) {
            const category = account.cards.find(c => c.id === changedCat.id) as Category | undefined;
            if (category) {
              category.budgetValue = changedCat.budgetValue;
            }
          }
        });
        return budget;
      });
      toast({ title: "Budget Updated", description: `${changedCategories.length} categories have been updated.` });
    };

    const handleExportAccountData = (accountId: string) => {
        if (!currentBudget) return;
        const account = accounts.find(a => a.id === accountId);
        if (!account || !account.cards) return;
        const dataToExport = {
            pockets: account.cards.filter(c => c.type === 'pocket').map(({ name, icon, color }) => ({ name, icon, color: color || getRandomColor() })),
            categories: account.cards.filter(c => c.type === 'category').map(c => { const cat = c as Category; return { name: cat.name, icon: cat.icon, budgetValue: cat.budgetValue, isRecurring: !!cat.isRecurring, color: cat.color || getRandomColor() } })
        };
        const blob = new Blob([JSON.stringify(dataToExport, null, 2)], { type: 'application/json' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `budgetpillars_export_${account.name.replace(/\s/g, '_')}.json`;
        link.click();
        URL.revokeObjectURL(link.href);
        toast({ title: `Exported data for ${account.name}` });
    };

    const handleTriggerImport = (accountId: string) => {
        setImportingToAccountId(accountId);
        fileInputRef.current?.click();
    };

    const handleFileSelected = async (event: React.ChangeEvent<HTMLInputElement>) => {
        if (!importingToAccountId || !event.target.files?.[0]) return;
        const file = event.target.files[0];
        const reader = new FileReader();
        reader.onload = async (e) => {
            try {
                const importedData = JSON.parse(e.target?.result as string);
                if (!importedData.pockets || !importedData.categories) throw new Error("Invalid format");
                updateCurrentBudget(budget => {
                    const account = budget.accounts.find(a => a.id === importingToAccountId);
                    if (!account?.cards) return budget;
                    importedData.pockets.forEach((p: any) => {
                        const existing = account.cards.find(c => c.type === 'pocket' && c.name === p.name) as Pocket | undefined;
                        if (existing) { existing.icon = p.icon; existing.color = p.color || getRandomColor(); }
                        else account.cards.push({ type: 'pocket', id: `pocket_${Date.now()}_${Math.random()}`, name: p.name, icon: p.icon, balance: 0, color: p.color || getRandomColor() });
                    });
                    importedData.categories.forEach((c: any) => {
                        const existing = account.cards.find(card => card.type === 'category' && card.name === c.name) as Category | undefined;
                        if (existing) { existing.budgetValue = c.budgetValue; existing.icon = c.icon; existing.isRecurring = !!c.isRecurring; existing.color = c.color || getRandomColor(); }
                        else account.cards.push({ type: 'category', id: `cat_${Date.now()}_${Math.random()}`, name: c.name, icon: c.icon, budgetValue: c.budgetValue, isRecurring: !!c.isRecurring, currentValue: 0, color: c.color || getRandomColor() });
                    });
                    return budget;
                });
                toast({ title: "Data Imported Successfully" });
            } catch (error) {
                toast({ title: "Import Failed", variant: "destructive" });
            } finally {
                setImportingToAccountId(null);
                if (fileInputRef.current) fileInputRef.current.value = "";
            }
        };
        reader.readAsText(file);
    };

    const handleClipboardImport = async (type: 'expense' | 'income', accountId?: string) => {
        const profile = importProfiles.find(p => p.smsStartWords || p.smsStopWords);
        if (!profile) {
            toast({ title: "SMS Rules Not Found", description: "Go to the Import page to set up SMS parsing rules.", variant: "destructive", duration: 6000 });
            return;
        }
        try {
            const clipboardText = await navigator.clipboard.readText();
            if (!clipboardText) {
                toast({ title: "Clipboard is empty", variant: "destructive" });
                return;
            }
            const result = extractSMSData(clipboardText, currency.code, profile.smsStartWords || '', profile.smsStopWords || '');
            const amount = parseFloat(result.amount);
            const date = new Date(result.date);
             if (isNaN(amount) || !isValid(date)) {
                throw new Error("Could not parse valid data from clipboard text.");
            }

            setParsedSmsData({ amount: Math.abs(amount), description: result.description, date });

            if (type === 'income' && accountId) {
                const account = accounts.find(a => a.id === accountId);
                if (account) dialogs.income.open(account);
            } else if (type === 'expense') {
                if (transactionCategory) dialogs.transaction.openForCategory(transactionCategory.accountId, transactionCategory.categoryId);
                else if (transactionPocket) dialogs.transaction.openForPocket(transactionPocket.accountId, transactionPocket.pocketId, transactionPocket.pocketName);
            }

        } catch (err) {
            toast({ title: "Parsing Failed", description: "Could not get data from clipboard. Check keywords on Import page.", variant: "destructive", duration: 6000 });
        }
    };

    const handlePasteTransaction = async (cardType: 'category' | 'pocket', cardId: string, cardName: string, accountId: string) => {
        const profile = importProfiles.find(p => p.smsStartWords || p.smsStopWords);
        if (!profile) {
            toast({ title: "SMS Rules Not Found", description: "Go to the Import page to set up SMS parsing rules.", variant: "destructive", duration: 6000 });
            return;
        }
        try {
            const clipboardText = await navigator.clipboard.readText();
            if (!clipboardText) {
                toast({ title: "Clipboard is empty", variant: "destructive" });
                return;
            }

            const result = extractSMSData(clipboardText, currency.code, profile.smsStartWords || '', profile.smsStopWords || '');
            const amount = parseFloat(result.amount);
            const date = new Date(result.date);
            if (isNaN(amount) || !isValid(date)) throw new Error("Parsed data is invalid.");

            const isDuplicate = transactions.some(tx => isSameDay(startOfDay(new Date(tx.date)), startOfDay(date)) && tx.amount === Math.abs(amount));

            if (isDuplicate) {
                setParsedSmsData({ amount: Math.abs(amount), description: result.description, date });
                if (cardType === 'category') dialogs.transaction.openForCategory(accountId, cardId);
                else dialogs.transaction.openForPocket(accountId, cardId, cardName);
            } else {
                if (cardType === 'category') {
                    // Open the transaction dialog pre-filled with the data
                    const account = accounts.find(a => a.id === accountId);
                    const category = account?.cards?.find(c => c.id === cardId && c.type === 'category') as Category | undefined;
                    if(category) {
                        setTransactionCategory({
                            accountId: accountId,
                            categoryId: cardId,
                            categoryName: cardName,
                            budgetValue: category.budgetValue,
                            currentValue: category.currentValue
                        });
                        setParsedSmsData({ amount: Math.abs(amount), description: result.description, date });
                        setTransactionDialogOpen(true);
                    }
                } else { // pocket
                    updateCurrentBudget(budget => {
                        const account = budget.accounts.find(a => a.id === accountId);
                        const pocket = account?.cards.find(c => c.id === cardId) as Pocket | undefined;
                        if (account && pocket) {
                            pocket.balance -= Math.abs(amount);
                            budget.transactions.unshift({ id: `txn_${Date.now()}`, amount: Math.abs(amount), description: result.description, date, accountId, categoryId: cardId, accountName: account.name, categoryName: `Expense: ${cardName}`, sourcePocketId: cardId });
                        }
                        return budget;
                    });
                    toast({ title: "Transaction Pasted" });
                }
            }

        } catch (err) {
            toast({ title: "Paste Failed", description: "Could not parse transaction from clipboard.", variant: "destructive" });
        }
    };

    const toggleAccountReordering = () => {
        setIsReorderingAccounts(prev => !prev);
        setReorderingAccountId(null);
    };

    const handleShareBudget = async (data: { email: string; permission: BudgetPermission; }) => {
        if (!user?.displayName || !user?.email) return;
        try {
            setIsSharing(true);
            await shareBudget(user.uid, user.displayName, user.email, data.email, data.permission);
            setSentShares(await getSentShares(user.uid));
            toast({ title: 'Invitation Sent!' });
        } catch (error) {
            toast({ title: 'Error', variant: 'destructive' });
        } finally { setIsSharing(false); }
    };

    const handleRevokeShare = async (share: ShareInvitation) => {
        if(!user) return;
        try {
            setIsSharing(true);
            await revokeShare(share);
            setSentShares(prev => prev.filter(s => s.id !== share.id));
            toast({ title: 'Access Revoked' });
        } catch (error) {
            toast({ title: 'Error', variant: 'destructive' });
        } finally { setIsSharing(false); }
    };

    const handleManageInvitation = async (invitationId: string, action: 'accept' | 'decline') => {
        if (!user?.email) return;
        try {
            await manageShareInvitation(invitationId, action, user.uid, user.email);
            setInvitations(prev => prev.filter(inv => inv.id !== invitationId));
            toast({ title: `Invitation ${action}ed!` });
            if (action === 'accept') window.location.reload();
        } catch(error) {
            toast({ title: 'Error', variant: 'destructive' });
        } finally { setIsSharing(false); }
    };

    const handleLinkPassword = async () => {
        if (!user || !linkPasswordData) return;
        try {
            const credential = EmailAuthProvider.credential(linkPasswordData.email, linkPasswordData.pass);
            await linkWithCredential(user, credential);
            toast({ title: "Password added!", description: "You can now sign in with your email and password." });
        } catch (error: any) {
            console.error("Error linking password:", error);
            toast({ title: "Linking failed", description: "Could not add password. Please try again.", variant: "destructive" });
        } finally {
            setLinkPasswordData(null);
        }
    };


    // --- DND Handlers ---
    const handleMouseDown = (e: React.MouseEvent) => { setIsDragging(true); setStartX(e.pageX - (e.currentTarget as HTMLDivElement).offsetLeft); setScrollLeft((e.currentTarget as HTMLDivElement).scrollLeft); };
    const handleMouseLeave = () => setIsDragging(false);
    const handleMouseUp = () => setIsDragging(false);
    const handleMouseMove = (e: React.MouseEvent) => {
        if (!isDragging || !(e.currentTarget as HTMLDivElement) || isReorderingAccounts || reorderingAccountId) return;
        e.preventDefault();
        const x = e.pageX - (e.currentTarget as HTMLDivElement).offsetLeft;
        const walk = x - startX;
        (e.currentTarget as HTMLDivElement).scrollLeft = scrollLeft - walk;
    };

    const handleDragEnd = (result: DropResult) => {
        const { source, destination, type } = result;
        if (!destination) return;
        updateCurrentBudget(budget => {
            if (type === 'ACCOUNT') {
                if (source.index === destination.index) return budget;
                const reorderedAccounts = Array.from(budget.accounts);
                const [removed] = reorderedAccounts.splice(source.index, 1);
                reorderedAccounts.splice(destination.index, 0, removed);
                budget.accounts = reorderedAccounts;
            } else {
                const sourceAccount = budget.accounts.find(a => a.id === source.droppableId);
                if (sourceAccount?.cards && source.droppableId === destination.droppableId) {
                    const reorderedCards = Array.from(sourceAccount.cards);
                    const [removed] = reorderedCards.splice(source.index, 1);
                    reorderedCards.splice(destination.index, 0, removed);
                    sourceAccount.cards = reorderedCards;
                }
            }
            return budget;
        });
    };

    const handleMoveAccount = (accountId: string, direction: 'left' | 'right') => {
        updateCurrentBudget(budget => {
            const index = budget.accounts.findIndex(a => a.id === accountId);
            if (index === -1) return budget;
            const newIndex = direction === 'left' ? index - 1 : index + 1;
            if (newIndex < 0 || newIndex >= budget.accounts.length) return budget;
            const reorderedAccounts = Array.from(budget.accounts);
            const [removed] = reorderedAccounts.splice(index, 1);
            reorderedAccounts.splice(newIndex, 0, removed);
            budget.accounts = reorderedAccounts;
            return budget;
        });
    };

    React.useEffect(() => {
        const handleKeyDown = (event: KeyboardEvent) => {
            if (event.key === 'Escape') {
                setTransferSource(null);
                setReorderingAccountId(null);
                setIsReorderingAccounts(false);
            }
        };
        if (transferSource || reorderingAccountId || isReorderingAccounts) {
            document.addEventListener('keydown', handleKeyDown);
        }
        return () => document.removeEventListener('keydown', handleKeyDown);
    }, [transferSource, reorderingAccountId, isReorderingAccounts]);


    // --- DIALOG OPEN/CLOSE LOGIC ---
    const dialogs = {
        account: {
            openAdd: () => {
                if (accounts.length >= ACCOUNT_LIMIT) {
                    toast({ title: "Account Limit Reached", variant: "destructive" });
                    return;
                }
                setEditingAccount(null);
                setAccountDialogOpen(true);
            },
            openEdit: (account: Account) => {
                setEditingAccount(account);
                setAccountDialogOpen(true);
            },
            close: () => setAccountDialogOpen(false),
            isOpen: isAccountDialogOpen,
        },
        category: {
            openAdd: (accountId: string) => {
                const account = accounts.find(a => a.id === accountId);
                if (account?.cards && account.cards.length >= CARDS_PER_ACCOUNT_LIMIT) {
                    toast({ title: "Card Limit Reached", variant: "destructive" });
                    return;
                }
                setEditingCategory(null);
                setAddingCategoryToAccount(accountId);
                setCategoryDialogOpen(true);
            },
            openEdit: (accountId: string, category: Category) => {
                setEditingCategory({ accountId, category });
                setCategoryDialogOpen(true);
            },
            close: () => {
                setCategoryDialogOpen(false);
                setEditingCategory(null);
                setAddingCategoryToAccount(null);
            },
            isOpen: isCategoryDialogOpen,
        },
        pocket: {
            openAdd: (accountId: string) => {
                const account = accounts.find(a => a.id === accountId);
                if (account?.cards && account.cards.length >= CARDS_PER_ACCOUNT_LIMIT) {
                    toast({ title: "Card Limit Reached", variant: "destructive" });
                    return;
                }
                setEditingPocket(null);
                setAddingPocketToAccount(accountId);
                setPocketDialogOpen(true);
            },
            openEdit: (accountId: string, pocket: Pocket) => {
                setEditingPocket({ accountId, pocket });
                setPocketDialogOpen(true);
            },
            close: () => {
                setPocketDialogOpen(false);
                setEditingPocket(null);
                setAddingPocketToAccount(null);
            },
            isOpen: isPocketDialogOpen,
        },
        transaction: {
            openForCategory: (accountId: string, categoryId: string) => {
                const account = accounts.find(a => a.id === accountId);
                const category = account?.cards?.find(c => c.id === categoryId && c.type === 'category') as Category | undefined;
                if (category) {
                    setTransactionCategory({ accountId, categoryId, categoryName: category.name, budgetValue: category.budgetValue, currentValue: category.currentValue });
                    setTransactionPocket(null);
                    setTransactionDialogOpen(true);
                }
            },
            openForPocket: (accountId: string, pocketId: string, pocketName: string) => {
                setTransactionCategory(null);
                setTransactionPocket({ accountId, pocketId, pocketName });
                setTransactionDialogOpen(true);
            },
            openForEdit: (transaction: Transaction) => {
                if (transaction.categoryName.startsWith('Income to') || transaction.categoryName.startsWith('Transfer:') || transaction.categoryName.startsWith('Expense:')) {
                    toast({ title: "Edit Not Supported", variant: "destructive" });
                    return;
                }
                setEditingTransaction(transaction);
                setTransactionDialogOpen(true);
            },
            close: () => {
                setTransactionDialogOpen(false);
                setEditingTransaction(null);
                setTransactionCategory(null);
                setTransactionPocket(null);
                setParsedSmsData(null);
            },
            isOpen: isTransactionDialogOpen,
        },
        income: {
            open: (account: Account) => {
                setAddingIncomeToAccount(account);
                setEditingRecurringIncome(null);
                setIncomeDialogOpen(true);
            },
            openForEdit: (income: RecurringIncome) => {
                const account = accounts.find(a => a.id === income.accountId);
                if (account) setAddingIncomeToAccount(account);
                setEditingRecurringIncome(income);
                setIncomeDialogOpen(true);
            },
            close: () => {
                setIncomeDialogOpen(false);
                setAddingIncomeToAccount(null);
                setParsedSmsData(null);
                setEditingRecurringIncome(null);
            },
            isOpen: isIncomeDialogOpen,
        },
        recurringIncomes: {
            open: (account: Account) => {
                setViewingRecurringIncomesFor(account);
                setRecurringIncomesDialogOpen(true);
            },
            close: () => {
                setRecurringIncomesDialogOpen(false);
                setViewingRecurringIncomesFor(null);
            },
            isOpen: isRecurringIncomesDialogOpen,
        },
        transactions: {
            open: () => {
                setTransactionsFilter('all');
                setTransactionsSheetOpen(true);
            },
            openForCategory: (categoryId: string, categoryName: string) => {
                setTransactionsFilter({ categoryId, categoryName });
                setTransactionsSheetOpen(true);
            },
            openForPocket: (pocketId: string, pocketName: string, accountId: string) => {
                setTransactionsFilter({ pocketId, pocketName, accountId });
                setTransactionsSheetOpen(true);
            },
            openForAccount: (accountId: string, accountName: string) => {
                setTransactionsFilter({ accountId, accountName });
                setTransactionsSheetOpen(true);
            },
            close: () => setTransactionsSheetOpen(false),
            isOpen: isTransactionsSheetOpen,
        },
        settings: {
            open: () => setSettingsDialogOpen(true),
            close: () => setSettingsDialogOpen(false),
            isOpen: isSettingsDialogOpen,
        },
        share: {
            open: async () => {
                if (!user) return;
                setIsSharing(true);
                setSentShares(await getSentShares(user.uid));
                setIsSharing(false);
                setShareDialogOpen(true);
            },
            close: () => setShareDialogOpen(false),
            isOpen: isShareDialogOpen,
        },
        invitations: {
            open: () => setInvitationsDialogOpen(true),
            close: () => setInvitationsDialogOpen(false),
            isOpen: isInvitationsDialogOpen,
        },
        cardDetails: {
            open: (card: Card, account: Account) => {
                setViewingCardDetails({ card, account });
                setCardDetailsDialogOpen(true);
            },
            close: () => {
                setCardDetailsDialogOpen(false);
                setViewingCardDetails(null);
            },
            isOpen: isCardDetailsDialogOpen,
        },
        budgetPlanner: {
            open: (account: Account) => {
                setPlanningForAccount(account);
                setBudgetPlannerOpen(true);
            },
            close: () => {
                setBudgetPlannerOpen(false);
                setPlanningForAccount(null);
            },
            isOpen: isBudgetPlannerOpen,
        }
    };

    return {
        state: {
            currentBudget,
            isLoading,
            accounts,
            transactions,
            transfer,
            transferSource,
            editingAccount,
            editingCategory,
            addingCategoryToAccount,
            editingPocket,
            addingPocketToAccount,
            transactionCategory,
            transactionPocket,
            editingTransaction,
            parsedSmsData,
            addingIncomeToAccount,
            editingRecurringIncome,
            viewingRecurringIncomesFor,
            selectedMonth,
            transactionsFilter,
            deleteTransactionId,
            isImportDialogOpen,
            templateBudget,
            reorderingAccountId,
            isReorderingAccounts,
            isDragging,
            sentShares,
            isSharing,
            invitations,
            activeBudget,
            linkPasswordData,
            viewingCardDetails,
            planningForAccount,
        },
        handlers: {
            handleImportBudget,
            executeImport,
            handleResetCategories,
            handleStartFromScratch,
            handleStartWithDemo,
            handleResetData,
            handleDeleteCurrentMonth,
            initiateTransfer,
            selectTransferTarget,
            cancelTransfer,
            handleTransferSubmit,
            handleSaveAccount,
            handleDeleteAccount,
            handleSaveCategory,
            handleDeleteCategory,
            handleSavePocket,
            handleDeletePocket,
            handleSaveTransaction,
            handleDeleteTransaction,
            handleQuickTransaction,
            handleAddIncome,
            handleSaveRecurringIncome,
            handleDeleteRecurringIncome,
            handleBudgetPlannerSubmit,
            handleExportAccountData,
            handleTriggerImport,
            handleFileSelected,
            toggleAccountReordering,
            setReorderingAccountId,
            handleShareBudget,
            handleRevokeShare,
            handleManageInvitation,
            handleSmsParse,
            setDeleteTransactionId,
            setImportDialogOpen,
            setTemplateBudget,
            setIsLoadingBudget,
            setTransactionsFilter,
            setLinkPasswordData,
            handleLinkPassword,
            handleClipboardImport,
            handlePasteTransaction,
            fileInputRef,
        },
        dndHandlers: {
            handleMouseDown,
            handleMouseLeave,
            handleMouseUp,
            handleMouseMove,
            handleDragEnd,
            handleMoveAccount,
        },
        dialogs,
    };

}
