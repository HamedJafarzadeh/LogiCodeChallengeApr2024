# Logitech Coding Challenge

This coding challenge read `logi.bin` file, which should exists in the same folder as `main.dart` and process it to get the sequence numbers and messages.


## Requirements
Write an application which can parse the logi.bin file and extract all the messages
including their sequence number. Please focus on presenting this data clearly and
effectively.
## Data
The attached binary file, logi.bin contains n messages. There are no incomplete
messages. Each message has the following packet structure:


[ Payload_Header ] [SEQ_Number] [ Message (String) ]

- The first 4 bytes represent the payload header as an Int32 (little endian) and
its value denotes the size of the message.
- The next 4 bytes represent the message sequence number. Again this is an
Int32 (little endian)
- The next n bytes represent the massage itself. The message is a string and its
size is defined in the aforementioned payload header.


## Consideration


There are two branches, showing two different methods that this can be done : 

Branch *main* is showing the simplest method where we read the whole `logi.bin` file into memory and then process it one by one.

Branch *Lazy_load* is showing a more memory efficient method to load progressively from file, process it to show the result and then moving to the next.

- As there are no incomplete message, there is no  need for searching for the packets, we can start step by step from first 4 bytes to get size of the string, the next 4 bytes to get the sequence number and then followed by n Bytes to read the message. Otherwise, we would have to search for the start of the packet and then read the message. In these cases we should usually use a data encoding methods, I personally like COBS(Consistent Overhead Byte Stuffing).
