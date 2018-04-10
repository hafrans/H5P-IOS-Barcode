##dcloud H5P QRBarcode module on iOS
---- 

再一次项目中发现官方使用的zxing有问题，有些QR码扫不出来，所以尝试将其更换

* 更换官方使用的zxing，使用系统原生提供的API
* 使用官方的liblibbarcode修改，直接可以使用，不需要再前台写其他的js代码

-- 
##问题
 * 只支持扫码，从相册选取尚未支持
 * 不支持闪光灯调整

##使用方式
将barcode拖进工程，再把dcloud默认使用的liblibbarcode.a 删除掉


目前的进度是满足我项目的需求（简简单单的扫QR码），如果有需要可以跟我发issue，我可以尝试继续开发。


*Apr 10 2018* 
