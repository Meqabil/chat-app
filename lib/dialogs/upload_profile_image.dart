import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadProgressDialog extends StatelessWidget {

  UploadProgressDialog({required this.uploadTask});
  final UploadTask uploadTask;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Uploading Image'),
      content: StreamBuilder<TaskSnapshot>(
        stream: uploadTask.snapshotEvents,
        builder: (BuildContext context, AsyncSnapshot<TaskSnapshot> snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            // Calculate the progress percentage
            double progress = snap.bytesTransferred / snap.totalBytes;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress), // Progress bar
                SizedBox(height: 20),
                Text('${(progress * 100).toStringAsFixed(2)} %'), // Show percentage
              ],
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(), // Default progress indicator
                SizedBox(height: 20),
                Text('0 %'), // Initial value before progress starts
              ],
            );
          }
        },
      ),
    );
  }
}
