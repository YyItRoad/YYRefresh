# YYRefresh
整合DZNEmptyDataSet 和 MJRefresh

###小记:

在扩展里`ScrollView`设置`DZNEmptyDataSetSource`时出现过不了`conformsToProtocol`检测。

后来通过`objc_getProtocol `获取到协议再使用`class_addProtocol`添加到当前类才解决。