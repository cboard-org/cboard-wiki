/* Title: UI tests architecture */

In order to test automatically Cboard's UI, we use [Webdriver](https://webdriver.io) with Selenium.

The specs could be found in `test/specs` and we have one for page/feature. There you can find `createPicto`, `home`, `login`, `root` and `settings` specs.

Given that Cboard is client side rendered, we need to wait for the page to be fully loaded before running tests. That's why we crated a `waitForPage` method that allow us to check if the page has been rendered.