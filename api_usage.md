其他服务登录

1. 生成Auth Token
`http://walletshark.aquarhead.me/token/new?service_id=13&service_secret=walletshark`

```
{
token: "f1ed7f3dfe3e92fd934f29d33dfb311840c2384c",
status: "fresh"
}
```

2. 重定向
`http://walletshark.aquarhead.me/user/login?token=f1ed7f3dfe3e92fd934f29d33dfb311840c2384c&redirect=google.com`

登录成功会重定向到
`https://www.google.com/?token=fcb86bf07716d4a6c19244343041b7082bc554d1&result=success`

(如果需要用户信息继续34, 否则保存token信息就行)
3. 通过Auth Token信息获取UID
`http://walletshark.aquarhead.me/token/info/f1ed7f3dfe3e92fd934f29d33dfb311840c2384c?service_id=13&service_secret=walletshark`

```
{
token: "f1ed7f3dfe3e92fd934f29d33dfb311840c2384c",
status: "authed",
expire_at: "2013-05-27T08:06:03-04:00",
used_at: "2013-05-27T07:37:07-04:00",
created_at: "2013-05-27T07:36:03-04:00",
user_id: 2,
service_provider_id: 1
}
```

4. 通过user_id获取用户信息 
`http://walletshark.aquarhead.me/user/info/1?service_id=13&service_secret=walletshark`

```
{
username: "aquarhead",
nickname: "AquarHEAD L.",
email: "aquarhead@gmail.com",
bind_phone: "",
actived: true,
grow_points: 0,
created_at: "2013-05-19T12:17:17-04:00",
updated_at: "2013-05-20T09:30:15-04:00"
}
```

其他服务支付

1. 生成Payment
`http://walletshark.aquarhead.me/payment/new?service_id=13&service_secret=walletshark&name=%E6%B5%8B%E8%AF%95wwqq%E6%9C%8D%E5%8A%A1%E5%99%A8&recipient=Nazgul&type=payment&amount=12.34`

参数:

- name: 交易名称
- recipient: 对方
- type: payment=支付(用户减钱) refund=退款(用户加钱) 等等..
- amount: 金额

```
{
token: "2013052707415214e8fca877dfd44b2b1cb5a1764c0b8f77507d1b",
name: "测试wwqq服务器",
type: "payment",
recipient: "Nazgul",
pay_amount: 12.34,
status: "pending",
status_msg: null,
ended_at: null,
created_at: "2013-05-27T07:41:52-04:00",
updated_at: "2013-05-27T07:41:52-04:00"
}
```

2. 重定向到支付页面
`http://walletshark.aquarhead.me/pay/2013052707415214e8fca877dfd44b2b1cb5a1764c0b8f77507d1b?success_callback=walletshark.aquarhead.me&failure_callback=walletshark.aquarhead.me`

3. 失败可以异步查询信息
`http://walletshark.aquarhead.me/payment/info/2013052707415214e8fca877dfd44b2b1cb5a1764c0b8f77507d1b?service_id=13&service_secret=walletshark`

```
{
token: "2013052707415214e8fca877dfd44b2b1cb5a1764c0b8f77507d1b",
name: "测试wwqq服务器",
type: "payment",
recipient: "Nazgul",
pay_amount: 12.34,
status: "pending",
status_msg: null,
ended_at: null,
created_at: "2013-05-27T07:41:52-04:00",
updated_at: "2013-05-27T07:43:56-04:00"
}
```

生成充值卡
`http://walletshark.aquarhead.me/genppcard?service_id=13&service_secret=walletshark&count=1&value=100`

默认密码123

```
[
{
identifier: "9577bfde34",
value: 100,
used_at: null,
expire_at: "2014-05-27T07:50:57-04:00",
created_at: "2013-05-27T07:50:57-04:00"
}
]
```