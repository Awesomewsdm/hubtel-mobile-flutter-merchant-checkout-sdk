import '../../network_manager/network_manager.dart';

class PreapprovalConfirm implements Serializable {
  String channel;
  String amount;
  String clientReference;
  String customerMsisdn;

  PreapprovalConfirm.create(
      this.channel, this.amount, this.clientReference, this.customerMsisdn);

  @override
  Map<String, dynamic> toMap() {
    return {
      "ChannelPassed": channel,
      "Amount": amount,
      "ClientReference": clientReference,
      "CustomerMsisdn": customerMsisdn
    };
  }
}
