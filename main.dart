import 'dart:io';
import 'dart:typed_data';

class Message {
  int length;
  int seqNumber;
  String msg;
  Message(this.length, this.seqNumber, this.msg);
}

/* @brief processLogiFile is a function that reads the logi.bin file and processes the content.
 * It reads the file content and extracts the length, sequence number, and the message.
 * @param filePath: A string that contains the path to the logi.bin file
 * @return List<Message>: A list of Message objects that contains the length, sequence number, and the message
 */
Future<List<Message>> processLogiFile(String filePath) async {
  List<Message> messages = [];
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
    messages.add(Message(length, seqNumber, message));
    i += 8 + length;
  }

  return messages;
}


/* @brief test is a function that tests the output of the processLogiFile function.
 * It checks if the output is as expected.
 * @param results: A list of Message objects that contains the length, sequence number, and the message
 * @return bool: A boolean value that indicates if the test passed or failed
 */
bool test(List<Message> results) {
  if (results.length != 3) {
    throw ("Test failed: Expected 3 messages, but got ${results.length}");
  }
  if (results[0].seqNumber != 0 ||
      results[0].msg != "Hello, welcome to Logitech!") {
    throw ("Test failed: Expected SeqNumber: 1, Message: Hello, welcome to Logitech!, but got SeqNumber: ${results[0].seqNumber}, Message: ${results[0].msg}");
  }
  if (results[1].seqNumber != 1 || results[1].msg.length != results[1].length) {
    throw ("Test failed: Expected SeqNumber: 2, ${results[1].seqNumber}, and Message length: ${results[1].length}, but got SeqNumber: ${results[1].seqNumber}, Message length: ${results[1].length}");
  }
  if (results[2].seqNumber != 2 ||
      results[2].msg != "This is the final message, Goodbye") {
    throw ("Test failed: Expected SeqNumber: 2, Message: This is the final message, Goodbye, but got SeqNumber: ${results[2].seqNumber}, Message: ${results[2].msg}");
  }

  return true;
}


Future main() async {
  try {
    var results = await processLogiFile('logi.bin');
    for (var result in results) {
      print("=====================================");
      print('SeqNumber: ${result.seqNumber}, Message: ${result.msg}');
    }
    print("\r\n \r\n===================TEST==================");
    if (test(results)) {
      print("Test Passed.");
    }
  } catch (e) {
    print(e);
  }

  return 0;
}
