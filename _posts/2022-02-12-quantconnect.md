---
title: QuantConnect入门
categories:
  - Blog
tags:
  - Trading
  - Python
---

Final Year Project要用QuantConnect做backtest。所以记录一下学习过程。

文档：https://www.quantconnect.com/docs/algorithm-reference/

# 目标程序：Short-Term Reversal

在最近的几次学习中，我总结了一个还不错的学习方式：找一个想看懂的程序，然后找文档，只看相关部分。目标就是把这个程序看懂，没别的。这可以有效避免一头扎进浩如烟海的文档中。

STR策略非常简单，只要买入超跌 卖出超涨就可以了。作为一个菜鸡，我认为超跌就是在我的stock universe中performance最差的一部分股票。超涨反之。

所以具体操作是：weekly rebalance。看最近一个月universe的performance，然后long 后10%，short前10%。

哦，universe是前100 large-cap US equity。主要流动性大手续费小。

代码如下：

```python
from clr import AddReference
AddReference("System.Core")
AddReference("System.Collections")
AddReference("QuantConnect.Common")
AddReference("QuantConnect.Algorithm")
import statistics
from datetime import datetime
from System.Collections.Generic import List

class ShortTimeReversal(QCAlgorithm):
    def Initialize(self):
        self.SetStartDate(2005, 1, 1)
        self.SetEndDate(2017, 5, 10)
        self.SetCash(1000000)
        
        self.UniverseSettings.Resolution = Resolution.Daily
        self.AddUniverse(self.CoarseSelectionFunction)
        self._numberOfSymbols = 100
        self._numberOfTradings = int(0.1 * self._numberOfSymbols)
        
        self._numOfWeeks = 0
        self._LastDay = -1
        self._ifWarmUp = False
        
        self._stocks = []
        self._values = {}

    def CoarseSelectionFunction(self, coarse):
        sortedByDollarVolume = sorted(coarse, key=lambda x: x.DollarVolume, reverse=True)
        top100 = sortedByDollarVolume[:self._numberOfSymbols]
        return [i.Symbol for i in top100]

    def OnData(self, data):
        
        if not self._ifWarmUp:
            if self._LastDay == -1:
                self._LastDay = self.Time.date()
                self._stocks = []
                self.uni_symbol = None
                symbols = self.UniverseManager.Keys
                for i in symbols:
                    if str(i.Value) == "QC-UNIVERSE-COARSE-USA":
                        self.uni_symbol = i
                for i in self.UniverseManager[self.uni_symbol].Members:
                    self._stocks.append(i.Value.Symbol)
                    self._values[i.Value.Symbol] = [self.Securities[i.Value.Symbol].Price]
            else:
                delta = self.Time.date() - self._LastDay
                if delta.days >= 7:
                    self._LastDay = self.Time.date()
                    for stock in self._stocks:
                        self._values[stock].append(self.Securities[stock].Price)
            self._numOfWeeks += 1
            if self._numOfWeeks == 3:
                self._ifWarmUp = True
        else:
            delta = self.Time.date() - self._LastDay
            if delta.days >= 7:
                self._LastDay = self.Time.date()
                
                returns = {}
                for stock in self._stocks:
                    newPrice = self.Securities[stock].Price
                    oldPrice = self._values[stock].pop(0)
                    self._values[stock].append(newPrice)
                    try:
                        returns[stock] = newPrice/oldPrice
                    except:
                        returns[stock] = 0

                newArr = [(v,k) for k,v in returns.items()]
                newArr.sort()
                for ret, stock in newArr[self._numberOfTradings:-self._numberOfTradings]:
                    if self.Portfolio[stock].Invested:
                        self.Liquidate(stock)
                for ret, stock in newArr[0:self._numberOfTradings]:
                    self.SetHoldings(stock, 0.5/self._numberOfTradings)
                for ret, stock in newArr[-self._numberOfTradings:]:
                    self.SetHoldings(stock, -0.5/self._numberOfTradings)
                self._LastDay = self.Time.date()
```

# Initialize
```python
class ShortTimeReversal(QCAlgorithm):
    def Initialize(self):
        self.SetStartDate(2005, 1, 1)
        self.SetEndDate(2017, 5, 10)
        self.SetCash(1000000)

        self.UniverseSettings.Resolution = Resolution.Daily
        self.AddUniverse(self.CoarseSelectionFunction)
        self._numberOfSymbols = 100
        self._numberOfTradings = int(0.1 * self._numberOfSymbols)
        
        self._numOfWeeks = 0
        self._LastDay = -1
        self._ifWarmUp = False
        
        self._stocks = []
        self._values = {}
```

所有的strategy都要继承QCAlgorithm。这个抽象父类定义了一些基本的属性和方法。

然后set回测时间范围，开始的cash。

resolution是数据精度（e.g. 分钟，小时，天）

AddUniverse(CoarseSelectionFunction)的意思是从一堆股票里选出一些。Coarse...的意思是粗删。在这个函数里只能根据price，volume等大属性筛选。这里根据market cap筛选，Coarse够用了。

100支股票，trade10次（？），ifWarmUp表示有没有warmup过。

stocks是挑的100个stock的ticker，values是map，key是100支股票ticker，value是过去四周100支股票价格的list。

# CoarseSelectFunction

```python
def CoarseSelectionFunction(self, coarse):
    sortedByDollarVolume = sorted(coarse, key=lambda x: x.DollarVolume, reverse=True)
    top100 = sortedByDollarVolume[:self._numberOfSymbols]
    return [i.Symbol for i in top100]
```

参数coarse应该就是一堆股票对象。根据DollarVolume切个100支出来就行。返回的是symbol的list。

# OnData

`OnData(self, data)`

这里的参数`data`是一个`Slice`对象。Slice汇总了一个时间点的价格数据。

价格数据会根据你设定的时间频率以Slice的形式feed进来，然后自动触发OnData()事件（或者说调用该函数）。所以可以说是event-driven？

# Warm-up

先看一下比较简单的warm-up。

在backtest刚开始的时候没有历史数据可以使用，这时就要先收集一会数据。

```python
if not self._ifWarmUp:
    if self._LastDay == -1:
        self._LastDay = self.Time.date()
        self._stocks = []
        self.uni_symbol = None
        symbols = self.UniverseManager.Keys
        for i in symbols:
            if str(i.Value) == "QC-UNIVERSE-COARSE-USA":
                self.uni_symbol = i
        for i in self.UniverseManager[self.uni_symbol].Members:
            self._stocks.append(i.Value.Symbol)
            self._values[i.Value.Symbol] = [self.Securities[i.Value.Symbol].Price]
    else:
        delta = self.Time.date() - self._LastDay
        if delta.days >= 7:
            self._LastDay = self.Time.date()
            for stock in self._stocks:
                self._values[stock].append(self.Securities[stock].Price)
    self._numOfWeeks += 1
    if self._numOfWeeks == 3:
        self._ifWarmUp = True
```

这段代码真的让我觉得python狗都不用，特别是doc也写得很烂的情况下。比如我完全搜不到UniverseManager的成员。

猜测一下，UniverseManager是一个map，它的Value是一堆universe里面的member。member就有一堆属性，比如symbol就是member.Value.Symbol。

（update：sample code貌似找不到这个QC什么什么的symbol了。smsb）

然后用这个symbol来定位某支股票，fill in stocks[]数组以及values{} map。这里有一个`self.Securities`。