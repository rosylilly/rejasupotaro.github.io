---
layout: post
title: "Androidのデータ保存パターン"
date: 2013-10-13 22:36
comments: false
categories: Android 
---

新しくアプリを作るときにAndroid内でのデータの持ち方や、アクセスの仕方、モデルの扱い方には色々あってどうしようってなると思うので、僕の少ない経験から考えたことをまとめます。

# ファイルに保存

DBは注意して使わないとデータがアップデートしたら全部消えましたとか、あるカラムだけデータが入ってませんでしたとかあるので、データの簡易保存、たとえばレスポンスのjsonをそのままキャッシュするとか、検索する必要がなかったりあまり更新しないモデルをシリアライズして保存するときにはファイル保存が向いていると思います。

なお、JavaのSerializableは柔軟性が低く、バージョンアップでデータを壊してアプリが落ちるということが分かっていてもハンドリングできなくて防ぐのが難しかったりするので、シリアライズするときはgsonとかmessagepackを使うことをオススメします。

ただこのやり方でもキャッシュを管理するためのFileManager的なクラスは必要になってくると思うので、あまり複雑なことをやるのであればDBを使った方が楽になってくると思います。
独自のFileManagerクラスを作り込んでしまうと新しく入ってきた人がつらいですしね。

# DBに保存(素SQL)

手でSQLを書くのはつらいです。人間はミスをするのでORMを使った方がいいと思います。

# ORM(ActiveAndroid)を利用してDBに保存
[ActiveRecordパターン](http://d.hatena.ne.jp/nattou_curry_2/20090102/1230903865)のORMです。

## モデル定義
```java
@Table(name = "Items")
public class Item extends Model {
  @Column(name = "Name", notNull = true, unique = true) // カラム名と制約を付けることができる　
  public String name; // ModelのFieldはpublicにしなければならない

  @Column(name = "Category") // リレーションが持てる
  public Category category;
}

@Table(name = "Categories")
public class Category extends Model {
  @Column(name = "Name")
  public String name;

  public List<Item> items() {
    return getMany(Item.class, "Category");
  }
}
```

### 補足

MedelのFieldに[Idが定義](https://github.com/pardom/ActiveAndroid/blob/91bca4983a7da882b6585f124288f1aac7b299ef/src/com/activeandroid/Model.java#LC40)されていて、テーブルを作るときに[Primary Keyになります。](https://github.com/pardom/ActiveAndroid/blob/91bca4983a7da882b6585f124288f1aac7b299ef/src/com/activeandroid/util/SQLiteUtils.java#LC161)
とはいえ内部的なIdだけでなく、サーバーからのレスポンスにIdも入っていると思うので、

```java
@Table(name = "Items")
public class Item extends Model {
    @Column(name = "ItemId")
    public String id;

    @Column(name = "Name", notNull = true, unique = true) // カラム名と制約を付けることができる　
    public String name; // ModelのFieldはpublicにしなければならない

    @Column(name = "Category") // リレーションが持てる
    public Category category;
}
```

このように親クラスのIdとカラム名が被らないように定義して `item.id` でアクセスするのはどうだろうかと考えています。ここでうっかり `item.getId()` とすると思っていたのと違う値が返ってくるとかあるので注意が必要です。

リリース後にモデルのフィールドを変更した際にはmigrationをする必要があります。詳しくはmigrationのところで書きますが、モデルの変更は注意が必要です。

## Query

### Save

```java
item = new Item();
item.category = restaurants;
item.name = "Red Robin";
item.save();
```

### Delete

```java
Item item = Item.load(Item.class, 1);
item.delete();
// or
new Delete().from(Item.class).where("Id = ?", 1).execute();
```

### Bulk insert

```java
ActiveAndroid.beginTransaction();
try {
        for (int i = 0; i < 100; i++) {
            Item item = new Item();
            item.name = "Example " + i;
            item.save();
        }
        ActiveAndroid.setTransactionSuccessful();
}
finally {
        ActiveAndroid.endTransaction();
}
```

トランザクションでラップすると40msで、使わないと4secかかるとのことです。


### 補足
[join、leftJoin、outerJoin、innerJoin、crossJoinもできます。](https://github.com/pardom/ActiveAndroid/blob/91bca4983a7da882b6585f124288f1aac7b299ef/src/com/activeandroid/query/From.java#LC54)

## Migration

`/assets/migraions/2.sql` のようにsqlを置いておくとonUpgradeで実行されます。
カラムを追加するだけなら以下の書けます。

```sql
ALTER TABLE Items ADD COLUMN price INTEGER;
```

migrationはバージョンアップ後にユーザーの手元で[順番に実行される](https://github.com/pardom/ActiveAndroid/blob/791652b3fbf130448a5b152d12764a451e421b47/src/com/activeandroid/DatabaseHelper.java#LC137)ので、アプリをインストールしてからしばらく期間をおいてからそのユーザーがアプリのバージョンアップをしたとすると、空いた期間分のマイグレーションが走って初回起動にやや時間がかかるかと思います。(そこまで大きな影響があるとは思いませんが)
起動時間より、migrationファイルを作り忘れたとかそっちの方がこわいので、モデルを変更するとき・レビューするときには気をつけて見たほうがよさそうです。

## その他ORMとの比較

```java
// GreenDAO
List<Todo> ended = daoSession.getTodoDao().queryBuilder()
        .where(new StringCondition(
            TodoDao.Properties.Status.columnName + "=?",
            Integer.toString(TodoDaoHelper.STATUS_END))).list();

// ActiveAndroid
new Select().from(Todo.class).where("Status=?", STATUS_END).execute();
```

greenDAOも見てみたのですが、daoSessionを引き回さないといけないのと、全体的に冗長だなという印象です。その分DAOの方がバグが入りにくそうなので、用途によって選択すればいいと思います。

See also:

- [Green DAO vs ORM lite vs Active Android](http://stackoverflow.com/questions/13680954/green-dao-vs-orm-lite-vs-active-android)
- [Comparing android ORM libraries - GreenDAO vs Ormlite](http://software-workshop.eu/content/comparing-android-orm-libraries-greendao-vs-ormlite)

# まとめ
キャッシュはファイルに保存して、モデルは要件に応じてORMを使ってDBに保存するのがいいと思います。
もしActiveAndroidを使うならAPIレスポンスをgsonとかで直接モデルに変換するとカオスになるのでentityを作るのがいいです、みたいにデータ保存はアプリの全体設計に関わってくるので、もし新しくアプリを作る場合はなるべく早い段階から検討をするといいと思います。
