import { LightningElement } from "lwc";

export default class SpiffIframe extends LightningElement {
  iframeUrl = "https://us1.spiff.com/"; // Changed from eu1 to us1, to solve MIS-8267 (ISRAEL CHAYON)
}
