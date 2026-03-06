({
  /*
   * When the v.value field changes its value, the lookup is loaded again
   */
  rerender: function (component, helper) {
    this.superRerender();
  }
});
