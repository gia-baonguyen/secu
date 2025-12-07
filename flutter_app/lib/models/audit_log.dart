class AuditLog {
  final int? logId;
  final String? tableName;
  final String? operation;
  final String? userId;
  final String? username;
  final String? recordId;
  final String? oldValues;
  final String? newValues;
  final DateTime? operationDate;
  final String? ipAddress;
  final String? sessionId;

  AuditLog({
    this.logId,
    this.tableName,
    this.operation,
    this.userId,
    this.username,
    this.recordId,
    this.oldValues,
    this.newValues,
    this.operationDate,
    this.ipAddress,
    this.sessionId,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      logId: json['logId'] as int?,
      tableName: json['tableName'] as String?,
      operation: json['operation'] as String?,
      userId: json['userId'] as String?,
      username: json['username'] as String?,
      recordId: json['recordId'] as String?,
      oldValues: json['oldValues'] as String?,
      newValues: json['newValues'] as String?,
      operationDate: json['operationDate'] != null
          ? DateTime.tryParse(json['operationDate'])
          : null,
      ipAddress: json['ipAddress'] as String?,
      sessionId: json['sessionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logId': logId,
      'tableName': tableName,
      'operation': operation,
      'userId': userId,
      'username': username,
      'recordId': recordId,
      'oldValues': oldValues,
      'newValues': newValues,
      'operationDate': operationDate?.toIso8601String(),
      'ipAddress': ipAddress,
      'sessionId': sessionId,
    };
  }

  bool get isInsert => operation == 'INSERT';
  bool get isUpdate => operation == 'UPDATE';
  bool get isDelete => operation == 'DELETE';
  bool get isSelect => operation == 'SELECT';

  String get operationDisplay {
    switch (operation) {
      case 'INSERT':
        return 'Created';
      case 'UPDATE':
        return 'Updated';
      case 'DELETE':
        return 'Deleted';
      case 'SELECT':
        return 'Viewed';
      default:
        return operation ?? 'Unknown';
    }
  }
}

