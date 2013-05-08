# WalletShark

[![Code Climate](https://codeclimate.com/github/AquarHEAD/WalletShark.png)](https://codeclimate.com/github/AquarHEAD/WalletShark)

A Personal Account Management module for our SE course at ZJU 2013 Spring-Summer.

## Interface

### Terminology

*Private* means (should) only available to other services in the system, but not end-user's clients.

*Public* means end-user's clients might be redirected to those API.

`service_id` & `service_secret` is generated for other services "manually", for identifying who's requesting our resources.

### Authorization

`/token/new?service_id=&service_secret=`

*Private*

Generate a auth token.

Since the end-user's client won't access this API (can even block that via local network api), it's safe to pass the secret directly in the request.

Before redirect to our login UI, other services should check cookies first, and check if the token hasn't expired.

`/token/info/[token_key]?service_id=&service_secret=`

*Private*

Get the token info specified by its `token_key` value.

The token would contain these fields:

### Login

`/login?token=&redirect=`

*Public*

A login UI, if login succeed will redirect to `redirect`, otherwise keep `token` and `redirect` and reload.

`/logout`

*Public*

Just the logout. (maybe need rethink)

### Payment

`/payment/new?service_id=&service_secret=`

*Private*

Create a new payment.

Needed arguments:

- Payment Name: some meaningful name describing the payment
- Payment Recipient: the other one involved in the payment
- Money Amount: how much money to pay
- Success Callback: callback on success
- Failure Callback: callback on failure
- Detail Link(optional): a link to where user can view the details
- Expire Time: how long is a payment valid

`/payment/info/[order_id]?service_id=&service_secret=`

*Private*

For checking payment status asynchronously.

`/pay/[payment_token]`

*Public*

After a payment is created, should redirect user to this UI.

### User Info

`/user/[id]`

*Private*

Return the user's info whose `id` is specified in the request.

## Internals

`/`

the welcome page.

`/home`

the user's home page.

`/signup`

sign up page.

`/edit`

edit user info page.

`/charge`

add money page.

`/history`

activity history page.

## Models

### User

- username: `string` cannot contain '@'
- email: `string`
- login_pass: `string` encrypted with bcrypt
- realname: `string`
- id_number: `string`
- payment_pass: `string` encrypted with bcrypt
- bind_phone: `string` (optional)
- sec_question: `string` (optional)
- sec_answer: `string` (optional)
- actived: `boolean`
- created_at: `datetime`
- updated_at: `datetime`
- grow_points: `float` (may need this extra info when pay for thing)
- balance: `decimal`

### AuthToken

- key: `string` a unique token
- status: `enum` fresh, authed, expired
- expire_at: `datetime` cannot be used later than this
- user: `foreignkey` if authed then set to the authed user's id
- created_at: `datetime`
- used_at: `datetime`

### ResetToken

- key: `string`
- user: `foreignkey` -> user.id
- type: `enum` login_password or payment_password
- used: `boolean`
- created_at: `datetime`
- used_at: `datetime`
- expire_at: `datetime`

### Payment

- token: `string`
- name: `string`
- type: `enum` inpour(充值), payment(付款), refund(退款), transfer(转账), gathering(收款)
- recipient: `string` to whom the payment is made
- pay_amount: `decimal` money amount
- user: `foreignkey`
- status: `enum` pending, succeed, failed, expired
- created_at: `datetime`
- updated_at: `datetime`
- ended_at: `datetime`

### PrepaidCard

- identifier: `string`
- password: `string`
- value: `decimal`
- created_at: `datetime`
- used_at: `datetime`
- expire_at: `datetime`
- user: `foreignkey`

### ServiceProvider

- service_id: `string`
- service_secret: `string`
- service_name: `string`