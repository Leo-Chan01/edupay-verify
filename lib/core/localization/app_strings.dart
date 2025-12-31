class AppStrings {
  // App
  static const String appTitle = 'EduPay Receipt Check';
  static const String online = 'Online';
  static const String offline = 'Offline';
  
  // Auth
  static const String adminLogin = 'Admin Login';
  static const String verifyReceiptAuth = 'Verify receipt authenticity';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String signIn = 'Sign In';
  static const String signingIn = 'Signing in...';
  static const String logout = 'Logout';
  static const String loggedOut = 'Logged out';
  static const String loginSuccessful = 'Login successful';
  static const String invalidCredentials = 'Invalid credentials';
  static const String pleaseEnterCredentials = 'Please enter both username and password';
  
  // Dashboard
  static const String welcome = 'Welcome';
  static const String home = 'Home';
  static const String verifyReceipt = 'Verify Receipt';
  
  // Verification Methods
  static const String scanQRCode = 'Scan QR Code';
  static const String scanQRCodeDesc = 'Scan receipt QR code';
  static const String manualSearch = 'Manual Search';
  static const String manualSearchDesc = 'Search by receipt ID';
  static const String scanReceiptQRCode = 'Scan Receipt QR Code';
  static const String pointCameraAtQR = 'Point camera at the QR code on the receipt';
  static const String enterReceiptID = 'Enter receipt ID or reference';
  static const String search = 'Search';
  static const String searchingReceipt = 'Searching...';
  static const String checkingReceipt = 'Checking receipt...';
  static const String pleaseEnterReceiptID = 'Please enter receipt ID';
  static const String qrScannerNotAvailable = 'QR scanner not available';
  
  // Receipt Details
  static const String receiptValid = 'VALID';
  static const String receiptInvalid = 'INVALID';
  static const String program = 'Program';
  static const String session = 'Session';
  static const String transactionID = 'Transaction ID';
  static const String description = 'Description';
  static const String amount = 'Amount';
  static const String paymentType = 'Payment Type';
  static const String totalPaid = 'Total Paid';
  static const String outstanding = 'Outstanding';
  static const String dateTime = 'Date & Time';
  static const String paymentMethod = 'Payment Method';
  static const String status = 'Status';
  static const String remarks = 'Remarks';
  static const String mode = 'Mode';
  static const String offlineVerification = 'Offline Verification';
  static const String receiptNotFound = 'Receipt not found';
  
  // History
  static const String history = 'History';
  static const String verificationHistory = 'Verification History';
  static const String clearHistory = 'Clear History';
  static const String clearAllHistory = 'Clear all verification history?';
  static const String historyCleared = 'History cleared';
  static const String noHistoryYet = 'No history yet';
  static const String noHistoryDesc = 'Verified receipts will appear here';
  static const String verifiedAt = 'Verified at';
  
  // Offline Management
  static const String offlineManagement = 'Offline Management';
  static const String downloadRecords = 'Download Records';
  static const String dateFrom = 'From Date';
  static const String dateTo = 'To Date';
  static const String download = 'Download';
  static const String downloading = 'Downloading...';
  static const String downloadingRecords = 'Downloading records...';
  static const String recordsDownloaded = 'records downloaded';
  static const String downloadFailed = 'Download failed';
  static const String downloadRequiresInternet = 'Download requires internet connection';
  static const String totalRecords = 'Total Records';
  static const String lastUpdated = 'Last Updated';
  static const String refresh = 'Refresh';
  static const String delete = 'Delete';
  static const String offlineDataRefreshed = 'Offline data refreshed';
  static const String deleteAllOfflineRecords = 'Delete all offline records?';
  static const String offlineDataDeleted = 'Offline data deleted';
  static const String dateRangeExceedsOneYear = 'Date range cannot exceed 1 year';
  static const String endDateMustBeAfterStartDate = 'End date must be after start date';
  static const String noOfflineDataAvailable = 'No offline data available';
  static const String noOfflineDataForSearch = 'No offline data available. Searching requires downloaded records. Would you like to go to the Offline section to download records first?';
  static const String noOfflineDataForQR = 'No offline data available. QR scanning requires downloaded records. Would you like to go to the Offline section to download records first?';
  
  // Connectivity
  static const String workingOffline = 'Working offline - QR scanning available with downloaded records';
  
  // General
  static const String cancel = 'Cancel';
  static const String ok = 'OK';
  static const String close = 'Close';
  static const String yes = 'Yes';
  static const String no = 'No';
}
