[![Build Status](https://travis-ci.org/mmmpa/active_record_samplooper.svg)](https://travis-ci.org/mmmpa/active_record_samplooper)
[![Coverage Status](https://coveralls.io/repos/mmmpa/yorisoi/badge.svg?branch=master)](https://coveralls.io/r/mmmpa/active_record_samplooper?branch=master)

# ActiveRecordSamplooper

ActiveRecordSamplooperはArray#sampleをActiveRecordでもやりたくて書かれました。

おもにテストデータ作成に使っています。

```ruby
SampleModel.sample
=> #<SampleModel:0x007ff4e2077068 id: 40, ast_name: "松尾", first_name: "寛治", last_name_reading: "まつお", first_name_reading: "かんじ", email: "matsuo_kanji@example.com", gender: "male", age: 74, birth: Wed, 26 Jun 1940, tel: "090-">
```
あるいは
```ruby
SampleModel.sample(3)
=> [
  #<SampleModel:0x007fb73ec99030  id: 16,  last_name: "七瀬",  first_name: "希",  last_name_reading: "ななせ",  first_name_reading: "のぞみ",  email: "nanase_nozomi@example.com",  gender: "female",  age: 64,  birth: Tue, 23 Jan 1951,  tel: "080-9991-7001">,
  #<SampleModel:0x007fb73d78c9f8  id: 29,  last_name: "長谷部",  first_name: "樹里",  last_name_reading: "はせべ",  first_name_reading: "じゅり",  email: "hasebe_juri@example.com",  gender: "female",  age: 43,  birth: Sat, 09 Oct 1971,  tel: "090-4943-9297">,
  #<SampleModel:0x007fb73d786d00  id: 29,  last_name: "長谷部",  first_name: "樹里",  last_name_reading: "はせべ",  first_name_reading: "じゅり",  email: "hasebe_juri@example.com",  gender: "female",  age: 43,  birth: Sat, 09 Oct 1971,  tel: "090-4943-9297">
]
```
`where`で絞って
```ruby
SampleModel.where(gender: :male).sample(10).map{|m| [m.first_name, m.gender].join(' : ')}
=> ["洋介 : male", "勇一 : male", "良介 : male", "晃司 : male", "仁晶 : male", "良介 : male", "一樹 : male", "明 : male", "禄郎 : male", "晃司 : male"]
```
ただしダイレクトに`sample`するより(Samplooper)[#Samplooper]を介した方がよさそう。

## Installation
```ruby
gem 'active_record_samplooper'
```
    $ bundle install

## Usage

`Samplooper`を介すと軽かったり多少便利だったりします。

***

### Samplooper

直接の`sample`のほかに、`sampler`メソッドで`Samplooper`インスタンスを取得、`Samplooper#sample` `Samplooper#pick` `Samplooper#loop`が行えます。
それぞれ引数に1以上の整数をとり、1の場合はレコードを、2以上の場合はレコードを含む配列を返します。
* **sample(n = 1)**  
先行取得したidたちを元にレコードを取得。被りあり。
* **pick(n = 1)**  
先行取得したidたちを元にレコードを取得。各レコードは1度のみ出現する。1周すると`nil`が帰ってくる。
* **loop(n = 1)**  
先行取得したidたちを元にレコードを取得。各レコードは1周に1度のみ出現する。

***

### sample

```ruby
sampler = SampleModel.limit(3).sampler
sampler.sample.id
=> 3
sampler.sample.id
=> 1
sampler.sample(15).map(&:id)
=> [3, 3, 2, 3, 1, 3, 3, 3, 1, 3, 1, 3, 2, 1, 1]
```

***

### pick

```ruby
sampler = SampleModel.limit(3).sampler
sampler.pick(5).map{ |m| m.try(:id)}
=> [2, 1, 3, nil, nil]

sampler = SampleModel.limit(3).sampler
sampler.pick.id
=> 1
sampler.pick(5).map{ |m| m.try(:id)}
=> [2, 3, nil, nil, nil]
```

***

### loop

```ruby
sampler = SampleModel.limit(3).sampler
sampler.loop.id
=> 2
sampler.loop.id
=> 1
sampler.loop.id
=> 3
sampler.loop(15).map(&:id)
=> [
  3, 1, 2,
  1, 3, 2,
  3, 1, 2,
  1, 2, 3,
  2, 3, 1
]
```

***

`where`とかも併用できます。
```ruby
SampleModel.where(gender: :male).sample(10).map{|m| [m.first_name, m.gender].join(' : ')}
=> ["洋介 : male", "勇一 : male", "良介 : male", "晃司 : male", "仁晶 : male", "良介 : male", "一樹 : male", "明 : male", "禄郎 : male", "晃司 : male"]
```
上は毎回ActiveRecord_Relation取ってくるのでちょっと遅いので`sampler`でidを先行取得して`sample`するとちょっと早い。
```ruby
sampler = SampleModel.where(gender: :male).sampler
sampler.sample(10).map{|m| [m.first_name, m.gender].join(' : ')}
=> ["悟志 : male", "良介 : male", "慎之介 : male", "寛治 : male", "浩正 : male", "隆之介 : male", "禄郎 : male", "浩正 : male", "一樹 : male", "良介 : male"]
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
