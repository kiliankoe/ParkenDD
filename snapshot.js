#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(3)
captureLocalizedScreenshot('0-lotlist')
target.frontMostApp().navigationBar().leftButton().tap();
target.delay(3)
captureLocalizedScreenshot('0-settings')
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.41, y:0.45}});
target.delay(8)
captureLocalizedScreenshot('0-schießgasse')
