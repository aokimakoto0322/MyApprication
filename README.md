
<h1>基礎代謝, カロリー記録アプリ - Caldate</h1>

<img src="https://user-images.githubusercontent.com/43976208/91845212-bb016580-ec93-11ea-913d-2a7c5fd5069f.png" width=20%>




<p>基礎代謝, カロリー記録アプリ - Caldateは日々摂取したカロリーを保存し振り返り確認することで健康状態を確認することができるアプリケーションです。</p>
<p>対応OSはAndroidとiOSになります。</p>
<ui>
    <li><a href="https://play.google.com/store/apps/details?id=com.makotoaoki.Caldate2">android版</a></li>
    <li><a href="https://apps.apple.com/us/app/id1487352735">iOS版</a></li>
</ui>

<h2>使用言語</h2>
<ui>
    <li><a href="https://dart.dev/">Dart 1.20.2</a></li>
    <li><a href="https://kotlinlang.org/">Kotlin 1.4.0</a></li>
    <li><a href="https://developer.apple.com/jp/swift/">Swift 5.2.4</a></li>
    <li><a href="https://developer.apple.com/jp/xcode/swiftui/">Swift UI</a></li>
</ui>

<h2>機能</h2>
<ui>
    <li><a href="#func1">カロリー保存</a></li>
    <li><a href="#func2">保存したカロリーのグラフ描画</a></li>
    <li><a href="#func3">基礎代謝計算</a></li>
    <li><a href="#func4">ご飯のカロリーデータ取得</a></li>
</ui>

<h3 name="func1">カロリー保存</h3>
<p>記入されたカロリー量を保存します。保存先はアプリ内に作成されたDBに保存されます。DBについては<a href="https://pub.dev/packages/sqflite">sqflite</a>を使用しております。</p>
<p>保存する日にちはスマートフォン端末内の日にちより取得してDBにカロリーと共に保存されます。</p>

![intro1](https://user-images.githubusercontent.com/43976208/91918972-76131880-ecff-11ea-9fe9-970a596e03aa.png)


<h3 name="func2">保存したカロリーのグラフ描画</h3>
<p>DBに保存されたデータの過去7日分をサマリーとして表示します。グラフの描画には<a href="https://pub.dev/packages/fl_chart">FLChart</a>
を使用しております。</p>

![intro2](https://user-images.githubusercontent.com/43976208/91937774-a671ab80-ed2d-11ea-9af9-2703518c4eaf.png)


<h3 name="func3">基礎代謝計算</h3>
<p>基礎代謝を測定することで今日食べたカロリー数と基礎代謝数を比較することができます。比較結果は円グラフで描画しております。</p>
<p>基礎代謝の算出にはハリス・ベネディクト方程式を利用して算出しております。また、算出された基礎代謝はアプリ内に作成したDBに永続的に保存されます。</p>

<p>※参考　ハリス・ベネディクト方程式</p>
<ui>
    <li>男性： 13.397×体重kg＋4.799×身長cm−5.677×年齢+88.362</li>
    <li>女性： 9.247×体重kg＋3.098×身長cm−4.33×年齢+447.593</li>
<ui>

<h3 name="func4">ご飯のカロリーデータ取得</h3>
<p>お店で購入した商品にはカロリーの記載があり、それを入力すれば簡単にカロリーを保存することができますが、それができないものもあります。例えば、ファストフード店の食べ物や自分で作った料理があたります。</p>
<p>それらを一括でDB化し一覧表示させることでユーザーがより簡単にカロリーの取得を行うことができます。</p>
<p>ご飯のカロリーデータのDBテーブルはアプリ内には置かず、ネットワークを通してデータを取得し、表示しております。これは後々ご飯のカロリーデータを拡充させる際にユーザーにアプリを再インストールさせる手間を軽減させるためです。</p>

![intro3](https://user-images.githubusercontent.com/43976208/91940417-5cd78f80-ed32-11ea-9188-6ba49be49d37.png)
