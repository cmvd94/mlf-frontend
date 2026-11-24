// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void printBillHtml(String htmlContent) {
  try {
    final iframe = html.IFrameElement();
    iframe.style.position = 'fixed';
    iframe.style.right = '0';
    iframe.style.bottom = '0';
    iframe.style.width = '0';
    iframe.style.height = '0';
    iframe.style.border = '0';
    html.document.body?.children.add(iframe);

    final win = iframe.contentWindow;
    if (win != null) {
      final doc = (win as dynamic).document;
      doc.open();
      doc.write(htmlContent);
      doc.close();
      Future.delayed(const Duration(milliseconds: 300), () {
        (win as dynamic).focus();
        (win as dynamic).print();
        Future.delayed(const Duration(seconds: 2), () {
          iframe.remove();
        });
      });
    } else {
      html.window.print();
    }
  } catch (e) {
    html.window.print();
  }
}
