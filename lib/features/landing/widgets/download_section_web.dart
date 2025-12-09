import 'dart:html' as html;

/// Web implementation for opening links in new tab
void openLinkInNewTab(String url) {
  html.window.open(url, '_blank');
}
