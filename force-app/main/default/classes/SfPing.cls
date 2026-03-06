@RestResource(urlMapping='/sf_ping')
global without sharing class SfPing {
  @HttpGet
  global static String ping() {
    return 'pong';
  }
}
