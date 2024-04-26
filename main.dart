import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class Message {
  int length;
  int seqNumber;
  String msg;
  Message(this.length, this.seqNumber, this.msg);
}

Stream<Uint8List> MockDataStream(String filePath) async* {
  await Future.delayed(Duration(seconds: 1));
  var LogiFile = File(filePath);
  var LogiFileContent = LogiFile.readAsBytesSync();
  // Split the file into chunks of random data
  for (var i = 0; i < LogiFileContent.length;) {
    var randomByteLength = Random().nextInt(10);
    yield LogiFileContent.sublist(
        i,
        (i + randomByteLength < LogiFileContent.length)
            ? i + randomByteLength
            : null);
    i += randomByteLength;
    await Future.delayed(Duration(milliseconds: 100));
  }
}

Future<List<Message>> processLogiFile(String filePath) async {
  Completer<List<Message>> completer = Completer();
  List<Message> messages = [];
  // Make sure that logi.bin exists
  if (!File(filePath).existsSync()) {
    throw ('$filePath not found');
  }
  // Load the file content
  List<int> localSmallBuffer = [];
  int length = -1;
  int seqNumber = -1;
  MockDataStream(filePath).listen((event) {
    print("Read a random chunk of data of length: ${event.length}");
    localSmallBuffer.addAll(event);
    if (localSmallBuffer.length > 8) {
      // Preamble is received in the buffer
      if (length == -1) {
        // if we have not received the length yet
        ByteData lengthBytes =
            Uint8List.fromList(localSmallBuffer).buffer.asByteData(0, 4);
        length = lengthBytes.getUint32(0, Endian.little);
        ByteData seqNumberBytes =
            Uint8List.fromList(localSmallBuffer).buffer.asByteData(4, 4);
        seqNumber = seqNumberBytes.getUint32(0, Endian.little);
      }

      if (localSmallBuffer.length >= 8 + length) {
        // We have received the full message
        String message = String.fromCharCodes(
            Uint8List.fromList(localSmallBuffer).sublist(8, 8 + length));
        messages.add(Message(length, seqNumber, message));
        // print(
        //     'SeqNumber: $seqNumber, Message: $message'); // For Debugging purpose
        localSmallBuffer = localSmallBuffer.sublist(8 + length);
        length = -1;
        seqNumber = -1;
      }
    }
  }).onDone(() {
    completer.complete(messages);
  });

  return completer.future;
}

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
    print("\r\n \r\n=================TEST====================");
    if (test(results) == true) {
      print("Test Passed.");
    }
    return 0;
  } catch (e) {
    print(e);
    return 1;
  }
}
