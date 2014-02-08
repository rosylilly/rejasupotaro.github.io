---
layout: post
title: "Intentの生成パターン"
date: 2013-10-17 00:02
comments: False
categories: Android
---

Androidの設計思想上、Activityはどこからも呼び出されるものなので、Intentを呼び出し元で生成してExtraを付けるっていうのは、どこでgetExtraされるかとか、そもそもどんなパラメータが必要かが分かりにくくて、後から追加されたActivityでExtraが足りなくて落ちるということが起こりうると思っていました。

## 僕のパターン
そこで僕は、IntentHubというクラスを作って、画面の呼び出しなどのIntent処理をまとめてそこに書くようにしています。

### 例.

```java
@InjectView(R.id.button) Button mButton;
@Inject IntentHub mIntentHub;

@Override
public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    mButton.setOnClickListener((view) ->
            mIntentHub.openCommentViewActivity(commentId);
    });
}
```

## GitHubのパターン
他のアプリはどうしてるのかなと思ってGitHubのAndroidアプリを見てみたら、IntentsというIntentを作るためのヘルパークラスがいて、BuilderでIntentを作って、IntentFilterで対象の画面の呼び出しをしていました。つまり…コードを見た方が早いと思います。

### 呼び出し先(CommitViewActivity)

```java
public static Intent createIntent(final Repository repository, final int position, final String... ids) {
    Builder builder = new Builder("commits.VIEW");
    builder.add(EXTRA_POSITION, position);
    builder.add(EXTRA_BASES, ids);
    builder.repo(repository);
    return builder.toIntent();
}
```

### 呼び出し元Activity(NewsFragment)
```java
startActivity(CommitViewActivity.createIntent(repo, sha));
```

### IntentFilterの定義(AndroidManifest)

```xml
<activity
    android:name=".ui.commit.CommitViewActivity"
    android:configChanges="orientation|keyboardHidden|screenSize" >
    <intent-filter>
        <action android:name="com.github.mobile.commits.VIEW" />

        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</activity>
```

いずれにせよ、呼び出し元のActivityで直接Intentを生成するのは良くなさそうという話でした。
