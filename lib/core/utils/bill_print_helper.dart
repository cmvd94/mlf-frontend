import 'bill_print_stub.dart' if (dart.library.html) 'bill_print_web.dart';

class BillPrintHelper {
  static void printBill(String htmlContent) {
    printBillHtml(htmlContent);
  }
}
