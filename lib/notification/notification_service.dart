import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationService {
  static Future<String> getAccessToken() async {
    final Map<String, String> serviceAccountJson = <String, String>{
      // "type": "service_account",
      // "project_id": "your-app-id",
      // "private_key_id": "047761d4128e47c6d4b198388ffdbff1e11692e5",
      // "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDWXEJp4s5d2XPs\nWjw6jadN2GWWP3Zp0S5feztRVzIIPIUV8pyYcRqLe4hod8Zto/9dhJJJBgMEjhn4\nMxqw4/VgoPI0TEfxOPueWpGxObmc4ML6TgFo/tyVUwC+rw9wBig0xvuak/vJAKOs\nKkrpbxOOHGmdgaH2I88PdZNQ32PklvcXWBUbZudSAC6KzZ79u09tmXGvdVB8C54v\nnOz0wpAWgkrWCL/m+F2utoIz+W/WiINEO4SovdSYV6CwyU5/TqUANOajRfa5LZvB\nsVs9UIOTVursqwBUCLuL2KSafLoIis8xFXqEweie/FhWmvZCTouyS+5xi43gZutC\nYnyCzCCXAgMBAAECggEAWZg2KguiNZet3BvbEJ4kT2UjEKl11MSZnU7kfBr1znt9\nJK9CxHSBo8r+OKvXQ/xHv86pVdwtZrn+IL87aLPe24Rpt3Iqn6gxgv5X5rs52VgY\nJoZ0EG51w/PtW8XPrgLkyypf/zvbAShDQLJsnSTQB5XYjvyftUFCSjPaXvL/zYqH\n6UHrXWWOBdWxD2jLboRZbalgYTrgrg8MSJkP55l0v8LEHurXB6DfQXrNc1+aVjHv\nbaY+6cNVZeH1ElS3+WEX71PMGBpwpJPvY3Z4a+6QSb1guGaUOOsMR6tUaOY2GsyI\nod3BQBVwDq3DGgkABq9550e78DDxW71b0WPdM0FwAQKBgQDqZIkcB7JUSwHG/Pj5\ngNcXoCibaiGLqJJlELm5nW8EEY4cGbAqi8LUNo/hzxnvPwz7PlK9XpmU2ymHtVIJ\nlY+ZaLYp74q2peB6l+gV7qlgffHdU3fxN7XdcYdGcFFA9fYa9saV33hO4NEGDU0r\nmDT6I+psIvauiFff2r+x/nxSrwKBgQDqHvpxm1KsV2hb18HagO5P28UKzqR/qI9o\nJumNDffEmyn6YjABJXP6Me0RAlvJD5eXR4BJiFOCWC0/X0MisBdoJgok9vXJDnk0\nYkE8A4WtUt/fCi2O0PdOE9Ea/Cn8puSFvPCojb+Unsmo8UP6XkqcHB9irnYN4TE3\nh1b9vXIqmQKBgCSiT/eskEeybXWvZi6A351Wr+IShWmxkCfxpEWJgKdvIvnrXehY\nbbwDRxuw5cnJ3fqKtB3a4kAsvOH0Cf1rfcUpY4dMZC7F4D7o7SI4agqlxJ6mBBIU\ndf1FWDI/LcPsbWmrdkBIbCJP6vt6KryMjoMmB+ac1FdVAf7/zoRAVSgLAoGANRBM\nZ09zD4jIKHjggSvT19nR8T8g3aZQyqR3LvdJfxBEFXIHu1rHzJ9gQgis0QdtrmYQ\nV5pEgziFGOX4i3Yp9/sXNYWb87QKGKtkabvKopw0DZN6+/G0+8dWD62zvoX9KarH\nSQzHrWHIBziX1bllY7ikDHPKYh72TsWoG97Cb5ECgYBAM5d7mHd1NCGg8zxrxCgs\n6SMSkFatLSu1iCOfEX5ggosOzlcX8jrmkexSAL7N1Uz6B6MOQ8l4uHTAsUjWVi5S\ndksnXm9BW9q/UPHWq+RSt23/RHoEPBkTiC/mK2ReMNkxbkPhK0cWLCPQW64hLttC\nNcVlr6EFwpQwAGUef4iCaQ==\n-----END PRIVATE KEY-----\n",
      // "client_email": "anything@your-app-id.iam.gserviceaccount.com",
      // "client_id": "104865748075107103031",
      // "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      // "token_uri": "https://oauth2.googleapis.com/token",
      // "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      // "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/anything@chat-7b2fa.iam.gserviceaccount.com",
      // "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    try {
      http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );
      auth.AccessCredentials credentials =
      await auth.obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client);
      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      print('Error obtaining access token: $e');
      throw e;
    }
  }

  static Future<void> sendNotification(String deviceToken,
      String title,
      String body,
      String myImage,
      String otherImage,
      String myId,
      String otherId,
      String myName,
      String otherName,
      String chatId
      ) async {
    try {
      final String accessToken = await getAccessToken();
      print('Access Token: $accessToken');
      String endpointFCM =
          'https://fcm.googleapis.com/v1/projects/chat-7b2fa/messages:send';
      final Map<String, dynamic> message = {
        "message": {
          "token": deviceToken,
          "notification": {"title": title, "body": body},
          "data": {
            "route": "serviceScreen",
            'myImage': myImage,
            'otherImage': otherImage,
            'myName': myName,
            'otherName': otherName,
            'myId': myId,
            'otherId':otherId,
            'chatId': chatId,
          }
        }
      };
      final http.Response response = await http.post(
        Uri.parse(endpointFCM),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
