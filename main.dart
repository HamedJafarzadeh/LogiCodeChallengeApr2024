import 'dart:io';
import 'dart:typed_data';

class Messages {
  int seqNumber;
  String Message;
  Messages(this.seqNumber, this.Message);
}

Future<List<Messages>> processLogiFile(String filePath) async {
  List<Messages> messages = [];
  // Make sure that logi.bin exists
  if (!File(filePath).existsSync()) {
    throw ('$filePath not found');
  }
  // Load the file content
  var logiFile = File(filePath);
  var logiFileContent = await logiFile.readAsBytes();

  // Here we should note that if we are dealing with a large dataset, loading all at once to the memory is not a good idea. This can result in memory overflow. In such cases, we should read the file in chunks. Refer to "LazyLoad" branch for this approach.

  for (var i = 0; i < logiFileContent.length;) {
    ByteData lengthBytes = logiFileContent.buffer.asByteData(i, 4);
    int length = lengthBytes.getUint32(0, Endian.little);
    ByteData seqNumberBytes = logiFileContent.buffer.asByteData(i + 4, 4);
    int seqNumber = seqNumberBytes.getUint32(0, Endian.little);
    String message =
        String.fromCharCodes(logiFileContent.sublist(i + 8, i + 8 + length));
    // print('i: $i Length: $length SeqNumber: $seqNumber, Message: $message'); // For Debugging purpose
    messages.add(Messages(seqNumber, message));
    i += 8 + length;
  }

  return messages;
}

Future main() async {
  var results = await processLogiFile('logi.bin');
  for (var result in results) {
    print("=====================================");
    print('SeqNumber: ${result.seqNumber}, Message: ${result.Message}');
  }

  return 0;
}
