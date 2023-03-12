import { test, expect } from '@playwright/test';

test('render image', async ({ page }) => {

  expect(process.env.RENDERNVIM_INPUT).toBeDefined();
  expect(process.env.RENDERNVIM_OUTPUT).toBeDefined();
  expect(process.env.RENDERNVIM_TYPE).toBeDefined();

  let options: Page.ScreenshotOptions = {
    path: process.env.RENDERNVIM_OUTPUT + '.' + process.env.RENDERNVIM_TYPE,
    type: process.env.RENDERNVIM_TYPE,
  };

  if ('RENDERNVIM_CLIP' in process.env) {
    options.clip = JSON.parse(process.env.RENDERNVIM_CLIP)
  }

  if ('RENDERNVIM_FULL_PAGE' in process.env) {
    options.fullPage = JSON.parse(process.env.RENDERNVIM_FULL_PAGE)
  } else {
    options.fullPage = true
  }

  if ('RENDERNVIM_SCALE' in process.env) {
    options.scale = process.env.RENDERNVIM_SCALE
  }

  if ('RENDERNVIM_CARET' in process.env) {
    options.caret = process.env.RENDERNVIM_CARET
  }

  if ('RENDERNVIM_OMIT_BG' in process.env) {
    options.omitBackground = JSON.parse(process.env.RENDERNVIM_OMIT_BG)
  } else {
    options.omitBackground = true
  }

  if ('RENDERNVIM_QUALITY' in process.env) {
    options.quality = +process.env.RENDERNVIM_QUALITY
  } 

  if ('RENDERNVIM_ANIMATIONS' in process.env) {
    options.animations = process.env.RENDERNVIM_ANIMATIONS
  }

  if ('RENDERNVIM_MASK' in process.env) {
    options.mask = JSON.parse(process.env.RENDERNVIM_MASK)
  }

  await page.goto('file://' + process.env.RENDERNVIM_INPUT);

  await page.screenshot(options);

});

