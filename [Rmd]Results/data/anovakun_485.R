# 【ANOVA君：要因計画のタイプと水準数を入力することにより，分散分析を行う関数】
# 1)フリーの統計ソフトウェア「R」で動作する関数
# 2)被験者間要因（独立測度），被験者内要因（反復測度）のいずれか，または，両方を含む各タイプの分散分析を扱う
# 3)引数としては，最初にデータフレーム名，次に計画のタイプ（""で囲むこと）を入力し，その後，各要因の水準数を順に入力する
# （作成：井関龍太）
# 
# 【使用法】
# anovakunに読み込むためのデータフレームは，以下のような形式で作っておく
# 1)被験者間要因はタテ，被験者内要因はヨコに並べる
# 2)被験者内要因を表す行はデータとして読み込まない（下の例では，点線より上の行は読み込まず，点線より下のデータのみ読み込む）
# 3)被験者間要因を表す列はデータとして読み込む（下の例では，a1などの文字を含む列；被験者間要因数が増えるたびにラベル用の列を増やす）
# 4)被験者間要因を表すラベルは，水準ごとに別の文字または数字を用いる（同じラベル＝同じ水準と見なされる）
# 5)被験者内，被験者間要因ともに，前の方の要因から順に各水準のデータを入れ子状に整理して並べること（例を参照）
# 6)下の被験者１～６の列は例の説明のためにつけたものなので，実際のデータフレームには必要ない
# 
# ［AsBC計画の例］（被験者間要因でデータ数が同じ）
# 		b1	b1	b2	b2
# 		c1	c2	c1	c2
# 	------------------------------------
# 	a1	12	9	14	13	---被験者１
# 	a1	13	10	14	12	---被験者２
# 	a1	11	10	13	15	---被験者３
# 	a2	18	12	16	15	---被験者４
# 	a2	17	14	15	14	---被験者５
# 	a2	15	13	18	15	---被験者６
# 
# データフレームを代入した変数名をxとすると，
# 
# > anovakun(x, "AsBC", 2, 2, 2)
# 
# のようにして関数を呼び出す
# 
# ［ABsC計画の例］（被験者間要因でデータ数がふぞろい）
# 			c1	c2
# 	-------------------------------
# 	a1	b1	3.5	4.2	---被験者１
# 	a1	b1	2.7	3.2	---被験者２
# 	a1	b2	2.5	3.8	---被験者３
# 	a1	b3	4.0	3.9	---被験者４
# 	a2	b1	3.3	4.0	---被験者５
# 	a2	b1	1.4	2.5	---被験者６
# 	a2	b2	3.7	4.2	---被験者７
# 	a2	b2	2.2	4.2	---被験者８
# 	a2	b3	1.3	2.1	---被験者９
# 	a2	b3	3.4	3.9	---被験者10
# 
# データフレームを代入した変数名をxとすると，
# 
# > anovakun(x, "ABsC", 2, 3, 2)
# 
# のようにして関数を呼び出す
# 
# 【オプション】
# 1)long……long = Tとすると，ロング形式のデータを読み込んで処理する
# 2)type2……type2 = Tとすると，平方和の計算方法をタイプⅡに切り替える
# 3)nopost……nopost = Tとすると，下位検定を実行しない
# 4)tech……テクニカルアウトプット；tech = Tとすると，データフレームをリストでつないだ形式で結果を出力する
# 5)data.frame……data.frame = Tとすると，計算に使用したデータフレームを出力する（関数中でdatと表現されているデータフレーム）
# 6)copy……copy = Tとすると，出力結果をクリップボードにもコピーする（クリップボードの内容は上書きされる）
# 7)holm……holm = Tとすると，多重比較の方法がHolmの方法になる
# 8)hc……hc = Tとすると，多重比較の方法がHolland-Copenhaverの方法になる
# 9)s2r……s2r = Tとすると，Shafferの方法のための仮説数の計算法を具体的な棄却のパターンに基づく方法に変更する（Rasmussenのアルゴリズムに基づく）
# 10)s2d……s2d = Tとすると，Shafferの方法のための仮説数の計算法を具体的な棄却のパターンに基づく方法に変更する（Donoghueのアルゴリズムに基づく）
# 11)fs1……fs1 = Tとすると，ステップ１の基準をステップ２の基準に置き換えた方法でShafferの方法を行う
# 12)fs2r……fs2r = Tとすると，Shaffer2の方法とF-Shaffer1の方法を組み合わせた方法でShafferの方法を行う（Rasmussenのアルゴリズムに基づく）
# 13)fs2d……fs2d = Tとすると，Shaffer2の方法とF-Shaffer1の方法を組み合わせた方法でShafferの方法を行う（Donoghueのアルゴリズムに基づく）
# 14)hc, s2r……hc = Tかつs2r = T（または，fs2r = T，s2d = T，fs2d = T）とすると，Shaffer2の基準を用いてHolland-Copenhaverの方法を行う
# 15)holm, hc……holm = Tかつhc = Tとすると，Holmの調整基準にSidakの不等式を用いた多重比較（Holm-Sidak法）を行う
# 16)welch……welch = Tとすると，多重比較の際にKeselman-Keselman-Shafferの統計量とWelch-Satterthwaiteの近似自由度を用いる
# 17)criteria……criteria = Tとすると，多重比較の出力において，調整済みｐ値の代わりに調整済みの有意水準を表示する
# 18)lb……lb = Tとすると，すべての被験者内効果に対してイプシロンの下限値（Lower Bound）による自由度の調整を行う（Geisser-Greenhouseの保守的検定）
# 19)gg……gg = Tとすると，すべての被験者内効果に対してGreehnouse-Geisserのイプシロンによる自由度の調整を行う
# 20)hf……hf = Tとすると，すべての被験者内効果に対してHuynh-Feldtのイプシロンによる自由度の調整を行う
# 21)cm……cm = Tとすると，すべての被験者内効果に対してChi-Mullerのイプシロンによる自由度の調整を行う
# 22)auto……auto = Tとすると，球面性検定が有意であった被験者内効果に対してGreehnouse-Geisserのイプシロンによる自由度の調整を行う
# 23)mau……mau = Tとすると，球面性検定の方法がMauchlyの球面性検定になる
# 24)har……har = Tとすると，球面性検定の方法がHarrisの多標本球面性検定になる
# 25)iga……iga = Tとすると，改良版一般近似検定を行う；イプシロンの代わりに各種の推定値を算出し，分散分析の際に適用する
# 26)ciga……ciga = Tとすると，修正改良版一般近似検定を行う；イプシロンの代わりに各種の推定値を算出し，分散分析の際に適用する
# 27)eta……eta = Tとすると，分散分析表にイータ二乗を追加する
# 28)peta……peta = Tとすると，分散分析表に偏イータ二乗を追加する
# 29)geta……geta = Tとすると，分散分析表に一般化イータ二乗を追加する；geta = "要因ラベル（A, B, C...）"とすると，指定した要因を測定要因と見なして一般化イータ二乗を計算する；
# 複数の要因を測定要因として指定するには，例えば，geta = c("A", "C")のようにする（計画に含まれない要因の指定は無効になる）
# 30)eps……eps = Tとすると，分散分析表にイプシロン二乗を追加する
# 31)peps……peps = Tとすると，分散分析表に偏イプシロン二乗を追加する
# 32)geps……geps = Tとすると，分散分析表に一般化イプシロン二乗を追加する；geps = "要因ラベル（A, B, C...）"とすると，指定した要因を測定要因と見なして一般化イプシロン二乗を計算する；
# 複数の要因を測定要因として指定するには，例えば，geps = c("A", "C")のようにする（計画に含まれない要因の指定は無効になる）
# 33)omega……omega = Tとすると，分散分析表にオメガ二乗（加算モデル）を追加する
# 34)omegana……omegana = Tとすると，分散分析表にオメガ二乗（非加算モデル）を追加する
# 35)pomega……pomega = Tとすると，分散分析表に偏オメガ二乗を追加する
# 36)gomega……gomega = Tとすると，分散分析表に一般化オメガ二乗（加算モデル）を追加する；gomega = "要因ラベル（A, B, C...）"とすると，指定した要因を測定要因と見なして一般化オメガ二乗を計算する；
# 複数の要因を測定要因として指定するには，例えば，gomega = c("A", "C")のようにする（計画に含まれない要因の指定は無効になる）
# 37)gomegana……gomegana = Tとすると，分散分析表に一般化オメガ二乗（非加算モデル）を追加する；gomegana = "要因ラベル（A, B, C...）"とすると，指定した要因を測定要因と見なして一般化オメガ二乗を計算する；
# 複数の要因を測定要因として指定するには，例えば，gomegana = c("A", "C")のようにする（計画に含まれない要因の指定は無効になる）
# 38)prep……prep = Tとすると，分散分析表にp_repを追加する
# 39)nesci……nesci = Tとすると，出力を指定している効果量について非心F分布に基づく信頼区間を算出する；このオプション単独では機能しないので注意；反復測定要因を含む効果と非加算モデルに基づく効果量については信頼区間を計算しない
# 40)besci……besci = Tとすると，出力を指定している効果量についてブートストラップに基づく信頼区間を算出する；このオプション単独では機能しないので注意
# 41)cilmd……cilmd = Tとすると，記述統計量の表に差分調整型のLoftus-Massonの信頼区間を追加する
# 42)cilm……cilm = Tとすると，記述統計量の表にLoftus-Massonの信頼区間を追加する
# 43)cind……cind = Tとすると，記述統計量の表に差分調整型の正規化に基づく信頼区間を追加する
# 44)cin……cin = Tとすると，記述統計量の表に正規化に基づく信頼区間を追加する
# 45)ciml……ciml = Tとすると，記述統計量の表にマルチレベルモデルに基づく信頼区間を追加する（lmerTestパッケージが必要）
# 46)cipaird……cipaird = Tとすると，差分調整型のペアワイズ信頼区間を出力する
# 47)cipair……cipair = Tとすると，ペアワイズ信頼区間を出力する
# 48)bgraph……bgraph = "信頼区間のオプション名"とすると，信頼区間つきの棒グラフを出力する；信頼区間は内側・外側の順に２つまで指定できる；
# 例えば，bgraph = c("cind", "ciml")とすると，差分調整型の正規化に基づく信頼区間とマルチレベルモデルに基づく信頼区間を描画する；
# なお，このオプションは３要因までの計画についてのみ機能する
# 
# ［オプション使用の例］（テクニカルアウトプットによる出力とHolmの方法による多重比較を指定）
# 
# > anovakun(x, "AsB", 2, 2, tech = T, holm = T)
# 
# 【技術情報】
# 1)anovakunを構成する関数は，仕様上は，最大で26要因までの計画に対応できる；この上限は，要因を表すラベルとしてアルファベット26文字（LETTERSとletters）を使用していることによる
# 2)ci.calc関数によるマルチレベルモデルに基づく信頼区間の計算には，lmerTestパッケージを使用している；自由度の推定にはlsmeans関数を用いている（Kenward-Roger法）
# 3)ss.calc関数は，デフォルトでは，タイプⅢ平方和の計算法に基づいて分散分析を行う
# 4)epsilon.calc関数は，デフォルトでは，被験者内要因を含むデータに対してMendozaの多標本球面性検定を行う（近似カイ二乗による）
# 5)epsilon.calc関数は，オプション指定により，被験者内要因を含むデータに対してMauchlyの球面性検定を行う（近似カイ二乗による）
# 6)epsilon.calc関数は，オプション指定により，被験者内要因を含むデータに対してHarrisの多標本球面性検定を行う（近似カイ二乗による）
# 7)epsilon.calc関数によるHuynh-Feldtのイプシロンの計算法は，Lecoutre（1991）の修正に基づく
# 8)epsilon.calc関数によるIGAとCIGAは，非加重平均を想定した計算法に基づく（Algina, 1997; Algina & Oshima, 1995）
# 9)anova.modeler関数は，IGAとCIGAを用いた際には，multiplier（b_hatとc_hat）によって調整した後のF値をF値の列に表示する
# 10)anova.modeler関数による加算モデルに基づくオメガ二乗，一般化オメガ二乗の計算式は，被験者と各要因の間のすべての交互作用が存在しないことを仮定するモデルによる（Dodd & Schultz, 1973を参照）
# 11)mod.Bon関数は，デフォルトでは，Shafferの方法による多重比較を行う（任意の棄却パターンにおける可能な真の帰無仮説の最大数に基づく方法）
# 12mod.Bon関数におけるShafferの方法，Holland-Copenhaverの方法の有意水準の計算は，Rasmussen（1993），Donoghue（2004）のアルゴリズムに基づく（オプションによる）
# 13)mod.Bon関数による多重比較では，p値の低い対から順に基準値よりも値が低いか否かを判定し，いったん有意でない対が見つかったら，
# 以降の対についてはすべて判断を保留する（p値が基準値を下回っても*マークを表示しない）；調整済みｐ値の表示の際には，調整済みｐ値が
# 既定の有意水準（５％）を下回った対にのみ*マークを表示する
# 14)pro.fraction関数は，単純主効果の検定において誤差項をプールしない（水準別誤差項を使用；サブセットに分散分析を再適用するのと同じ）
# 
# 【このファイルの含む関数】
# hmean……調和平均を計算する
# read.clip……クリップボードの情報を読み込む
# anovakun……プロセス全体の制御を行う
# uni.long……データフレームをロング形式に変形する
# ci.calc……平均の信頼区間を計算する
# ci.bars……信頼区間つきの棒グラフを作る
# elematch……文字列中のすべての要素を含む文字列をマッチングする
# expand.gmatrix……ベクトルの組み合わせを作る
# sig.sign……有意水準に合わせて記号を表示する
# epsilon.calc……Greenhouse-GeisserとHuynh-Feldtのイプシロンを計算する
# ss.calc……平方和を計算する
# qlambda.ncf……非心F分布のパラメータの信頼限界を算出する
# anova.modeler……分散分析表を作る
# mpginv……ムーア・ペンローズの逆行列を計算する
# wj.calc……Welch-Jamesアプローチに基づく近似検定を行う
# mod.Bon……修正Bonferroniの方法による多重比較を行う
# post.analyses……下位検定を行う
# pro.fraction……効果のタイプに適した下位検定を割り当てる
# boot.esci……ブートストラップ法に基づいて効果量の信頼区間を計算する
# boot.anova……主分析と単純主効果の検定の効果量を一括して計算する
# boot.inter……単純主効果の検定の効果量のみを計算する
# anova.output……出力の種類ごとに設定を割り当てる
# table.out……データフレームに書式を与えて出力する
# mod.Bon.out……修正Bonferroniの方法による多重比較の結果を出力する
# simeffects.out……単純主効果の検定の結果を出力する
# anovatan……指定した要因についてデータを分割して単純効果の検定を行う
# 
# 【バージョン情報】
# 1)anovakun version 1.0.0（R 2.5.1作成；2007/09/03公開）
# ・分散分析，単純主効果の検定，多重比較
# 2)anovakun version 2.0.0（R 2.5.1作成；2007/10/01公開）
# ・球面性検定とイプシロン調整；epsilon.calc関数の追加とそれに伴う変更
# ・平方和の計算方法を修正；ss.calc関数の修正とelematch関数の追加，それに伴う変更
# ・多重比較を行う際に，他の要因の効果を考慮した上でのMSeを用いてｔ統計量を計算するように修正；mod.Bon関数と関連する部分の改修
# 3)anovakun version 2.1.0（R 2.5.1作成；2007/11/01公開）
# ・平方和の計算方法を変更し，高速化を試みる；ss.calc関数の変更；その他，最適化
# 4)anovakun version 2.2.0（R 2.5.1，R 2.6.0作成；2007/12/03公開）
# ・QR分解の方法をLAPACKに変更し，高速化を試みる；その他の修正
# 5)anovakun version 3.0.0（R 2.5.1，R 2.6.0作成；2008/01/04公開）
# ・タイプⅢ平方和を計算する機能を追加（タイプⅢをデフォルトに設定）；ss.calc関数の変更とそれに伴う変更
# ・Shafferの方法のための可能な真の帰無仮説の数の計算アルゴリズムを追加；mod.Bon関数の変更とshaffer2，fshaffer1，fshaffer2オプションの追加
# ・多重比較の出力において調整済みｐ値を表示する機能を追加（デフォルトに設定）；mod.Bon関数の変更とそれに伴う変更
# 6)anovakun version 3.1.0（R 2.5.1，R 2.6.0作成；2008/02/01公開）
# ・aov関数のアルゴリズムを利用して誤差平方和の計算の高速化を試みる；ss.calc関数の変更；その他の修正
# 7)anovakun version 3.2.0（R 2.5.1，R 2.6.0作成；2008/04/01公開）
# ・Shafferの方法のための別バージョンのアルゴリズムを追加；mod.Bon関数の変更とs2d，fs2dオプションの追加
# ・オプション名の変更；“shaffer2，fshaffer1，fshaffer2”を“s2r，fs1，fs2r”に変更
# ・効果量とp_repを計算する機能を追加；anova.modeler関数，anovatab.out関数ほかの変更
# 8)anovakun version 4.0.0（R 2.5.1，R 2.6.0，R 2.7.0作成；2008/06/02公開）
# ・Mendozaの多標本球面性検定とHarrisの多標本球面性検定を行う機能を追加（Mendozaをデフォルトに設定）；epsilon.calc関数と関連する部分の変更
# ・Huynhの改良版一般近似検定とAlgina-Lecoutreの修正改良版一般近似検定を行う機能を追加；epsilon.calc関数及び関連する箇所の変更
# ・取り扱い可能な要因の数を拡張；anovakun関数，anova.modeler関数，epsilon.calc関数，pro.fraction関数ほかの変更
# ・複数の効果量をオプション指定したときに，すべての指標が同時に出力されるように変更；anova.modeler関数，pro.fraction関数ほかの変更
# 9)anovakun version 4.1.0（R 2.9.0，R 2.9.1，R 2.9.2作成；2009/09/01公開）
# ・欠損値があるケース（数値以外のデータを含む行）を除外して分析するように変更
# ・混合要因計画で被験者間要因のみを取り出して下位検定を行う際に警告メッセージが表示される点を修正
# 10)anovakun version 4.1.1（R 2.9.2，R 2.10.0，R 2.10.1作成；2010/01/04公開）
# ・Rのバージョン情報の表示を修正
# ・出力関数の表示エラーを修正；anovatab.out関数，simeffects.out関数の修正
# 11)anovakun version 4.2.0（R 2.10.0，R 2.10.1，R 2.11.1作成；2010/07/01公開）
# ・効果量の指標にイータ二乗，一般化イータ二乗，オメガ二乗，一般化オメガ二乗を追加；anova.modeler関数，anovatab.out関数ほかの変更
# ・データフレームの作成方法を変更；被験者間ラベルに文字列を使用しても指定した水準とデータがずれないようにする
# ・Lecoutre（1991）に基づいてHyunh-Feldtのイプシロンの計算式を変更；epsilon.calc関数の修正
# 12)anovakun version 4.3.0（R 2.14.1，R 2.14.2，R 2.15.0作成；2012/07/02公開）
# ・効果量の指標にイプシロン二乗，偏イプシロン二乗，一般化イプシロン二乗を追加；anova.modeler関数，pro.fraction関数ほかの変更
# ・オメガ二乗，偏オメガ二乗，一般化オメガ二乗の計算式を修正；anova.modeler関数，pro.fraction関数ほかの修正
# ・非加算モデルに基づくオメガ二乗，一般化オメガ二乗のオプションを追加；anova.modeler関数，pro.fraction関数ほかの修正
# ・結果をクリップボードにも出力するオプションcopyを追加（Linuxでは無効）；anovakun関数の変更
# 13)anovakun version 4.3.1（R 2.15.0，R 2.15.1作成；2012/09/03公開）
# ・copy機能がMacで働かないエラーを修正；anovakun関数の修正 
# 14)anovakun version 4.3.2（R 2.15.2作成；2013/01/04公開）
# ・read.clip関数を追加
# ・nopostオプションを追加；anovakun関数，post.analysis関数の変更
# ・copy機能がLinuxで働くように修正（xclipをインストールしている場合のみ機能）；anovakun関数の変更
# ・出力の桁数に合わせて表の長さを調節するように変更；bstat.out関数，anovatab.out関数，mod.Bon.out関数，simeffects.out関数，post.out関数，each.out関数の変更
# 15)anovakun version 4.3.3（R 2.15.3，R 3.0.0作成；2013/05/07公開）
# ・R 3.0.0で動作するように修正；ss.calc関数の修正
# ・３要因以上の分析で一次の交互作用が有意だった際の多重比較の独立・非独立測度への割り当てが誤っていたのを修正；pro.fraction関数の修正
# ・出力桁数の調整；anovatab.out関数ほかの修正
# 16)anovakun version 4.4.0（R 3.0.1，R 3.0.2作成；2013/11/01公開）
# ・データフレームの変形手順を変更し，ロング形式のデータも扱えるように変更；anovakun関数の変更
# ・出力時の要因名，水準名を任意に指定できるように変更；anovakun関数，anova.modeler関数，post.analyses関数，pro.fraction関数ほかの変更
# ・出力表示の調整；bstat.out関数，anovatab.out関数，mod.Bon.out関数，simeffects.out関数，post.out関数，each.out関数の変更
# ・一般化効果量における複数の測定要因を指定する方法を変更（cまたはlist形式を使用する）；anova.modeler関数，pro.fraction関数の変更
# 17)anovakun version 4.5.0（R 3.0.2作成；2014/02/03公開）
# ・信頼区間を計算する機能を追加；ci.calc関数の追加，anovakun関数，bstat.out関数の変更
# ・データフレーム変形部分をuni.long関数として分離；uni.long関数の追加，anovakun関数の変更
# ・３要因以上の計画について単純効果を扱うための関数を追加；anovatan関数の追加
# 18)anovakun version 4.5.1（R 3.0.2作成；2014/03/03公開）
# ・２つ以上の被験者間要因を含む計画での信頼区間算出の誤りを修正；ci.calc関数の修正
# ・信頼区間のオプションを追加；ci.calc関数の変更
# 19)anovakun version 4.6.0（R 3.0.2，R 3.1.0作成；2014/06/02公開）
# ・球面性検定の有意確率の算出を漸近展開を求める方式に変更；epsilon.calc関数の修正
# ・Chi-Mullerのイプシロンを計算し，自由度調整を行う機能を追加；epsilon.calc関数，anova.modeler関数ほかの変更
# ・サンプルサイズの多い反復測定要因を扱った場合の計算を高速化；ss.calc関数，epsilon.calc関数，anova.modeler関数ほかの変更
# 20)anovakun version 4.6.1（R 3.1.0作成；2014/07/01公開）
# ・4.6.0における変更に伴ってIGA，CIGA，anovatanを適用できなくなっていた点を修正；anova.modeler関数，anovatan関数の修正
# 21)anovakun version 4.6.2（R 3.1.0，R 3.1.1作成；2014/09/01公開）
# ・マルチレベルモデルに基づく信頼区間を算出するためのパッケージをlmerTestに変更；ci.calc関数の変更
# ・信頼区間つきの棒グラフを出力する機能の追加；ci.bars関数の追加
# ・多重比較の検定統計量としてWelch方式の統計量を計算する機能を追加；mpginv関数，wj.calc関数の追加，mod.Bon関数ほかの修正
# 22)anovakun version 4.7.0（R 3.1.0，R 3.1.1，R 3.1.2作成；2015/01/05公開）
# ・非心F分布に基づいて効果量の信頼区間を計算する機能を追加；qlamdba.ncf関数の追加；anova.modeler関数ほかの変更
# ・ブートストラップ法に基づいて効果量の信頼区間を計算する機能を追加；boot.esci関数，boot.anova関数，boot.inter関数の追加；その他関数の変更
# ・出力関数の変更；anova.output関数，table.out関数の追加；その他の関数の変更と削除
# 23)anovakun version 4.7.1（R 3.1.2，R 3.1.3作成；2015/04/01公開）
# ・３つ以上の被験者内要因を含むデザインでの自由度の割り当てのエラーを修正；episolon.calc関数の修正
# ・type2オプションが機能しなくなっていた点を修正；ss.calc関数の修正
# 24)anvoakun version 4.7.2（R 3.2.1，R 3.2.2作成；2015/10/01公開）
# ・単純主効果の検定の出力割り当てエラーほかの修正；pro.fraction関数の修正
# 25)anovakun version 4.8.0（R 3.2.2，R 3.2.3作成；2016/02/01公開）
# ・Huynhの改良版一般近似検定とAlgina-Lecoutreの修正改良版一般近似検定の修正；epsilon.calc関数ほかの修正
# 26)anovakun version 4.8.1（R 3.4.0，R 3.4.1作成；2017/08/01公開）
# ・long形式のデータを入力したときに起こるソートのエラーを修正；uni.long関数の修正
# 27)anovakun version 4.8.2（R 3.4.2作成；2018/01/04公開）
# ・techオプションを指定したときにブートストラップ効果量が出力されないエラーを修正；anovakun関数の修正
# 28)anovakun version 4.8.3（R 3.5.3，R 3.6.0作成；2019/07/01公開）
# ・long形式のデータを入力したときに起こるソートのエラーを修正；uni.long関数の修正
# ・iga，cigaオプションを指定したときに起こる出力エラーを修正；table.out関数の修正
# 29)anovakun version 4.8.4（R 3.6.1作成；2019/11/01公開）
# ・４つ以上の被験者内要因を含むデザインでの平方和のソートのエラーを修正；epsilon.calc関数の修正
# 30)anovakun version 4.8.5（R 4.0.0作成；2020/05/01公開）
# ・R 4.0.0における仕様変更に伴う修正；table.out関数の修正
#
# 【この関数の使用に関して】
# 1)anovakunとこれを構成する関数（コード群）は，自由に使用，改変，再配布していただいて結構です。
# 2)ただし，改変を加えたものを公開する際には，改変を加えたことを明記し，メインの関数の名前をanovakun以外の名前に変更してください。
# 3)anovakunとこれを構成する関数（コード群）の使用によって生じるいかなる結果に関しても作成者は責任を負いかねますのでご了承ください。


# 調和平均を計算する関数
hmean <- function(datvector){
	return(length(datvector)/sum(1/datvector))
}


# クリップボードの情報を読み込む関数
# read.tableのラッパー関数；read.tableの出力先以外のオプションをすべて指定できる
# OSにかかわらず同じ書式で機能するようにしてある；ただし，LinuxはUbuntuでのみテストしており，xclipをインストールしていることを前提とする
read.clip <- function(...){
	# OSごとのクリップボードを出力先に指定
	plat.info <- .Platform
	if(sum(grep("windows", plat.info)) != 0){# Windowsの場合
		outboard <- "clipboard"
	}else if(sum(grep("mac", plat.info)) != 0){# Macの場合
		outboard <- pipe("pbpaste")
	}else if(sum(grep("linux", R.version$system)) != 0){# Linuxの場合（xclipをインストールしている必要がある）
		system("xclip -o | xclip -sel primary")
		outboard <- "clipboard"
	}else{# いずれのOSでもない場合
		stop(message = "Unknown operating system!!")
	}

	# read.table関数を実行
	read.table(file = outboard, ...)
}


# ANOVA君本体：プロセス全体の制御を行う関数
anovakun <- function(dataset, design, ..., long = FALSE, type2 = FALSE, nopost = FALSE, tech = FALSE, data.frame = FALSE, copy = FALSE, 
	holm = FALSE, hc = FALSE, s2r = FALSE, s2d = FALSE, fs1 = FALSE, fs2r = FALSE, fs2d = FALSE, welch = FALSE, criteria = FALSE, 
	lb = FALSE, gg = FALSE, hf = FALSE, cm = FALSE, auto = FALSE, mau = FALSE, har = FALSE, iga = FALSE, ciga = FALSE, 
	eta = FALSE, peta = FALSE, geta = NA, eps = FALSE, peps = FALSE, geps = NA, omega = FALSE, omegana = FALSE, pomega = FALSE, 
	gomega = NA, gomegana = NA, prep = FALSE, nesci = FALSE, besci = FALSE, cilmd = FALSE, cilm = FALSE, cind = FALSE, cin = FALSE, 
	ciml = FALSE, cipaird = FALSE, cipair = FALSE, bgraph = c(NA, NA)){
	maxfact <- nchar(design) - 1# 実験計画全体における要因数

	# データフレームの変形
	datform <- uni.long(dataset = dataset, design = design, ... = ..., long = long)
	dat <- datform$dat
	factnames <- datform$factnames
	flev <- datform$flev
	miscase <- datform$miscase

	# 記述統計量を計算する
	if(sum(is.na(bgraph)) < 2){# 棒グラフに指定された信頼区間のオプションはオンにする
		eval(parse(text = paste0(bgraph, " <- TRUE")))
	}
	baseresults <- ci.calc(dat = dat, design = design, factnames = factnames, 
		cilmd = cilmd, cilm = cilm, cind = cind, cin = cin, ciml = ciml, cipaird = cipaird, cipair = cipair)

	# anova.modelerにデータフレームを送り，分散分析の結果を得る
	mainresults <- anova.modeler(dat = dat, design = design, factnames = factnames, type2 = type2, lb = lb, gg = gg, hf = hf, 
		cm = cm, auto = auto, mau = mau, har = har, iga = iga, ciga = ciga, eta = eta, peta = peta, geta = geta, 
		eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, pomega = pomega, gomega = gomega, 
		gomegana = gomegana, prep = prep, nesci = nesci)

	# post.analysesにデータフレームと分散分析の結果を送り，下位検定の結果を得る
	postresults <- post.analyses(dat = dat, design = design, factnames = factnames, mainresults = mainresults, type2 = type2, 
		nopost = nopost, holm = holm, hc = hc, s2r = s2r, s2d = s2d, fs1 = fs1, fs2r = fs2r, fs2d = fs2d, welch = welch, 
		criteria = criteria, lb = lb, gg = gg, hf = hf, cm = cm, auto = auto, mau = mau, har = har, iga = iga, ciga = ciga, 
		eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, pomega = pomega, 
		gomega = gomega, gomegana = gomegana, prep = prep, nesci = nesci)

	# 指定のあった効果量についてブートストラップ信頼区間を計算する
	if(besci){
		bootes <- boot.esci(dat, design, factnames = factnames, type2 = type2, nopost = nopost, mainresults = mainresults, 
			postresults = postresults, lb = lb, gg = gg, hf = hf, cm = cm, auto = auto, mau = mau, har = har, iga = iga, ciga = ciga, 
			eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, 
			pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep, B = 2000, conf.level = 0.95)
		mainresults$besci.info <- bootes$besci.info
		mainresults$bescitab <- bootes$bescitab[[1]]
		if(length(bootes$bescitab) > 1){# 単純主効果の結果も報告する場合
			postnames <- names(postresults)
			intnames <- postnames[nchar(postnames) == 3]# 単純主効果の検定を行ったリストのラベル
			for(i in 1:length(intnames)){
				postresults[[intnames[i]]]$bescitab <- bootes$bescitab[[i + 1]]
			}
		}
	}

	# 基本情報の取得
	info1 <- paste0("[ ", design, "-Type Design ]")# 要因計画の型
	info2 <- paste0("This output was generated by anovakun 4.8.5 under ", strsplit(R.version$version.string, " \\(")[[1]][1], ".")# バージョン情報など
	info3 <- paste0("It was executed on ", date(), ".")# 実行日時
	exe.info <- c(info1, info2, info3)

	# Unbalancedデザイン（データ数ふぞろい）の場合，プロンプトを追加
	if(length(unique(baseresults$bstatist$n)) != 1){
		if(type2 == TRUE) mainresults$ano.info1 <- append(mainresults$ano.info1, c("== This data is UNBALANCED!! ==", "== Type II SS is applied. =="))
		else mainresults$ano.info1 <- append(mainresults$ano.info1, c("== This data is UNBALANCED!! ==", "== Type III SS is applied. =="))
	}

	# 除外したケースの報告
	if(miscase != 0){
		baseresults$bstat.info1 <- append(baseresults$bstat.info1, paste0("== The number of removed case is ", miscase, ". =="))
	}

	# 結果を表示する
	if(copy){# 指定があった場合，出力をクリップボードにコピー
		plat.info <- .Platform
		if(sum(grep("windows", plat.info)) != 0){# Windowsの場合
			sink("clipboard", split = TRUE)
		}else if(sum(grep("mac", plat.info)) != 0){# Macの場合
			tclip <- pipe("pbcopy", "w")
			sink(tclip, split = TRUE)
		}else if(sum(grep("linux", R.version$system)) != 0){# Linxの場合（xclipをインストールしている必要がある）
			tclip <- pipe("xclip -selection clipboard")
			sink(tclip, split = TRUE)
		}
	}
	if(tech){# データフレーム形式での出力の場合
		postnames <- names(postresults)
		intnames <- postnames[nchar(postnames) == 3]# 単純主効果の検定を行ったリストのラベル
		if(length(intnames) > 0){
			for(i in intnames){
				postresults[[i]] <- postresults[[i]][-(7:9)]# sim.dmat，sim.cellN，sim.flevをカット
			}
		}
		if(is.null(mainresults$besci.info)){
			retlist <-list("INFORMATION" = rbind(info1, info2, info3), 
				"DESCRIPTIVE STATISTICS" = baseresults, 
				"SPHERICITY INDICES" = list(mainresults$epsi.info1, mainresults$epsitab), 
				"ANOVA TABLE" = list(mainresults$ano.info1, mainresults$anovatab, mainresults$nescitab), 
				"POST ANALYSES" = postresults)
		}else{
			retlist <-list("INFORMATION" = rbind(info1, info2, info3), 
				"DESCRIPTIVE STATISTICS" = baseresults, 
				"SPHERICITY INDICES" = list(mainresults$epsi.info1, mainresults$epsitab), 
				"ANOVA TABLE" = list(mainresults$ano.info1, mainresults$anovatab, mainresults$nescitab), 
				"EFFECT SIZE INFORMATION" = list(mainresults$besci.info, mainresults$bescitab), 
				"POST ANALYSES" = postresults)
		}
		if(data.frame == TRUE){
			names(dat) <- c("s", factnames, "y")
			retlist <- c(retlist, list("DATA.FRAME" = dat))# 計算に使用したデータフレームを付加
		}
		return(retlist)
	}else{# 表形式での出力の場合
		if(data.frame == TRUE){
			names(dat) <- c("s", factnames, "y")
			anova.output(maxfact = maxfact, exe.info = exe.info, baseresults = baseresults, 
				mainresults = mainresults, postresults = postresults)
			return(list("DATA.FRAME" = dat))# 計算に使用したデータフレームを付加
		}else{
			anova.output(maxfact = maxfact, exe.info = exe.info, baseresults = baseresults, 
				mainresults = mainresults, postresults = postresults)
		}
	}
	if(copy){
		sink()
		if(plat.info$OS.type != "windows"){# Mac，Linuxの場合
			close(tclip)
		}
	}

	# 指定があった場合には，棒グラフを出力
	if(sum(is.na(bgraph)) < 2 & maxfact <= 3){
		ci.bars(dat, design, factnames = factnames, inn.tier = bgraph[1], out.tier = bgraph[2])
	}
}


# データフレームをロング形式に変形する関数
uni.long <- function(dataset, design, ..., long = FALSE){
	maxfact <- nchar(design) - 1# 実験計画全体における要因数
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数
	levlist <- list(...)

	# データフレームの変形
	if(long){# ロング形式のデータフレームのヘッダをANOVA君に適合したものに変更
		# 指定されたデザインとデータフレームの列数が合致しない場合にはメッセージを表示して終了
		if((maxfact + 2) != ncol(dataset)){
			stop(message = "\"anovakun\" has stopped working...\nThe entered design does not match the data.")
		}

		# ヘッダの差し替え
		misv <- suppressWarnings(as.numeric(sapply(dataset[, ncol(dataset)], function(x) as.vector(x))))# 数値以外の値をNAに強制変換
		dat <- cbind(data.frame(lapply(dataset[, 1:(maxfact+1), drop = FALSE], function(x) factor(x, levels = unique(x)))), misv)# ラベルをfactor型に変換
		if(setequal(names(dataset), paste0("V", 1:ncol(dataset))) == TRUE | is.null(names(dataset)) == TRUE){# 入力時に指定されていない場合
			factnames <- LETTERS[1:maxfact]# 要因名のラベルとしてアルファベットを使用
			levlist <- lapply(1:maxfact, function(x) paste0(letters[x], 1:length(unique(dataset[, x+1]))))
			for(i in 1:maxfact){# 被験者間要因の水準名を小文字アルファベットにする
				levels(dat[, i+1]) <- levlist[[i]]# 水準名を上書き
			}
		}else{# 入力時に指定されている場合
			factnames <- names(dataset)[-c(1, maxfact+2)]# もとのヘッダを保存；要因名のラベルとして使用
		}

		dat <- dat[do.call(order, dat[c((betlen+2):(ncol(dat)-1), 2:betlen)]), ]
		names(dat) <- c("s", LETTERS[1:maxfact], "y")
		flev <- sapply(dat, nlevels)[-c(1, maxfact+2)]# 各要因の水準数
		attributes(flev) <- NULL# attributesを消去

		# 欠損値の除去
		if(!anyNA(misv)){# 欠損がなかった場合
			miscase <- 0# 欠損ケースの数
		}else{# 欠損があった場合
			misid <- dataset[is.na(misv), 1]# 欠損のあったID
			dat <- dat[rowSums(sapply(misid, function(x) x == dat[, 1])) == 0, ]# datからNAを含むIDの行（ケース）を除く
			miscase <- length(misid)# 欠損ケースの数
		}
	}else{# ワイド形式のデータフレームをロング形式に変換
		# 各要因の水準数と要因ラベルの設定
		if(is.null(names(levlist))){# 入力時に指定されていない場合
			flev <- unlist(levlist)# 各要因の水準数
			factnames <- LETTERS[1:maxfact]# 要因名のラベル
			levlist <- lapply(1:length(flev), function(x) paste0(letters[x], 1:flev[x]))
		}else{# 入力時に指定されている場合
			flev <- sapply(levlist, length)# 各要因の水準数
			attributes(flev) <- NULL# attributesを消去
			factnames <- names(levlist)# 要因名のラベル
		}

		# 水準数１が指定されていたらメッセージを表示して終了；存在しないオプション名が指定されると水準数１と解釈される
		if(min(flev) == 1){
			stop(message = "\"anovakun\" has stopped working...\nSome factor specifies only one level.\nOr maybe non-existent option-names are requested.")
		}

		# 指定されたデザインとデータフレームの列数が合致しない場合にはメッセージを表示して終了
		if((betlen + ifelse(is.na(prod(flev[(betlen+1):length(flev)])), 1, prod(flev[(betlen+1):length(flev)]))) != ncol(dataset)){
			stop(message = "\"anovakun\" has stopped working...\nThe entered design does not match the data.")
		}

		# 欠損値の除去
		misv <- suppressWarnings(as.numeric(sapply(dataset[, (betlen+1):ncol(dataset)], function(x) as.vector(x))))# 数値以外の値をNAに強制変換
		cdata <- array(misv, c(nrow(dataset), ncol(dataset) - betlen))# NAを含む行列
		compcase <- complete.cases(cdata)# 完全ケース
		dataset <- dataset[compcase, ]# datasetからNAを含む行（ケース）を除く
		miscase <- sum(!compcase)# 欠損ケースの数
		depv <- as.vector(cdata[compcase, ])# 従属変数をベクトル化
		slab <- rep(paste0("s", 1:nrow(dataset)), ncol(dataset) - betlen)# 被験者のラベル
		dat <- data.frame(factor(slab, levels = unique(slab)))# 被験者のラベルをデータフレームにする

		# 被験者間要因を含む場合
		if(betlen > 0){
			betlab <- data.frame(lapply(dataset[, 1:betlen, drop = FALSE], function(x) factor(x, levels = unique(x))))# 被験者間要因のラベルをfactor型に変換；水準名をもとの順序にそろえる
			for(i in 1:betlen){# 被験者間要因の水準名を小文字アルファベットにする
				levels(betlab[, i]) <- levlist[[i]]# 水準名を上書き
			}
			betlab <- do.call("rbind", replicate(ncol(dataset) - betlen, betlab, simplify = FALSE))# くりかえし数のぶんだけ増やす
			dat <- cbind(dat, betlab)# データフレームに追加
		}
		# 被験者内要因を含む場合
		if(withlen > 0){
			eachcue <- c(sapply(1:withlen, function(x) prod(flev[(betlen+x):maxfact])), 1)[-1]
			timescue <- prod(flev[(betlen+1):maxfact]) / (eachcue * flev[(betlen+1):maxfact])
			withlab <- data.frame(lapply(1:withlen, function(x) factor(rep(levlist[[betlen+x]], each = nrow(dataset) * eachcue[x], 
				times = timescue[x]), levels = levlist[[betlen+x]])))# 各被験者内要因の各水準を表すデータフレーム
			dat <- cbind(dat, withlab)# データフレームに追加
		}
		dat <- cbind(dat, depv)# 従属変数をデータフレームに追加
		names(dat) <- c("s", LETTERS[1:maxfact], "y")
	}
	return(list("dat" = dat, "factnames" = factnames, "flev" = flev, "miscase" = miscase))
}


# 平均の信頼区間を計算する関数
ci.calc <- function(dat, design, factnames = NA, conf.level = 0.95, cilmd = FALSE, cilm = FALSE, cind = FALSE, cin = FALSE, ciml = FALSE, cipaird = FALSE, cipair = FALSE){
	maxfact <- nchar(design) - 1
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数
	cellN <- length(unique(dat$s))# 被験者間要因をつぶしての全被験者の数
	flev <- sapply(2:(maxfact+1), function(x) nlevels(dat[, x]))# 各要因の水準数
	comlev <- prod(flev[(betlen+1):maxfact])# すべての被験者内要因の組み合わせ水準数
	bstat.info1 <- NULL
	bstat.info2 <- NULL

	# factnamesが省略されているときは名前をつける
	if(anyNA(factnames)) factnames <- LETTERS[1:maxfact]

	# 各条件ごとの平均と標準偏差を計算する
	tabbase <- tapply(dat$y, dat[, (maxfact+1):2], function(x) x)
	sncol <- sapply(tabbase, function(x) length(x))# セルごとのデータ数を計算
	mncol <- sapply(tabbase, function(x) mean(x, na.rm = TRUE))# セルごとの平均を計算
	sdcol <- sapply(tabbase, function(x) sd(x, na.rm = TRUE))# セルごとの標準偏差を計算

	# 記述統計量の表において各要因の各水準を表すためのラベル（数字列）を作成
	maincols <- expand.grid(lapply((maxfact+1):2, function(x) levels(dat[, x])))
	maincols <- maincols[, order(maxfact:1)]# アルファベット順に列を並べ替え

	# 記述統計量をデータフレームにまとめる
	bstatist <- data.frame(maincols, sncol, mncol, sdcol)
	names(bstatist) <- c(factnames, "n", "Mean", "S.D.")# 要因のラベルほかを列名に設定

	# Loftus-Massonの信頼区間の計算
	if(cilmd || cilm){
		# プールした平方和と自由度の計算
		pSS <- sum(dat$y^2) - sum(tapply(dat$y, interaction(dat[, 2:(maxfact+1)]), function(x) sum(x)^2/length(x)))
		pDF <- nrow(dat) - prod(flev)

		# 被験者内計画の場合は，被験者の誤差項の影響を除く
		if(betlen == 0){
			pSS <- pSS - (comlev * sum(tapply(dat$y, list(dat$s), function(x) mean(x)^2)) - sum(dat$y)^2/nrow(dat))
			pDF <- pDF - (cellN - 1)
		}

		ci.tval <- qt((1 - conf.level)/2, pDF, lower.tail = FALSE) * sqrt(pSS / pDF * mean(1/sncol))

		# 指定のあった指標を表に追加
		if(cilmd){
			bstat.info1 <- append(bstat.info1, "== Loftus-Masson's Difference-Adjusted Pooled Confidence Intervals ==")
			bstatist <- cbind(bstatist, "CILMD-L" = mncol - ci.tval / sqrt(2), "CILMD-U" = mncol + ci.tval / sqrt(2))
		}
		if(cilm){
			bstat.info1 <- append(bstat.info1, "== Loftus-Masson's Pooled Confidence Intervals ==")
			bstatist <- cbind(bstatist, "CILM-L" = mncol - ci.tval, "CILM-U" = mncol + ci.tval)
		}
	}

	# 正規化に基づく信頼区間の計算
	if(cind || cin){
		# 計画に合った計算法を適用
		if(withlen == 0){# 被験者間計画の場合
			nd.info <- "== Difference-Adjusted Confidence Intervals for Independent Means =="
			n.info <- "== Confidence Intervals for Independent Means =="
			vcom <- as.vector(tapply(dat$y, dat[, (betlen+1):2], function(x) sd(x)/sqrt(length(x))))
			ci.tval <- qt((1 - conf.level)/2, sncol - 1, lower.tail = FALSE) * vcom
		}else{# 反復測定要因を含む場合
			nd.info <- "== Cousineau-Morey-Baguley's Difference-Adjusted Normalized Confidence Intervals =="
			n.info <- "== Cousineau-Morey's Normalized Confidence Intervals =="
			if(betlen == 0){# 被験者間要因がないとき（被験者内計画の場合）
				caldat <- list(dat)
			}else{# １つ以上の被験者間要因があるとき（混合要因計画の場合）
				caldat <- split(dat, dat[, (maxfact+1-withlen):2])
			}

			wdat <- lapply(caldat, function(x) data.frame(matrix(x$y[order(eval(parse(text = paste0("x[, ", c(1, (maxfact+1):(betlen+2)), "]"))))], length(x$y)/comlev, comlev)))# データをワイド形式のデータフレームに変換；tapplyによるアクセス順に対応させるための並べ替え
			normdat <- lapply(wdat, function(x) x - matrix(rowMeans(x, na.rm = TRUE), nrow(x), 1) + mean(colMeans(x, na.rm = TRUE), na.rm = TRUE))# 個人ごとのデータによって正規化したデータ
			nsd <- unlist(lapply(normdat, function(x) sapply(x, function(y) sd(y, na.rm = TRUE))), use.names = FALSE)# 正規化したデータを使って標準偏差を計算
			ci.tval <- qt((1 - conf.level)/2, sncol - 1, lower.tail = FALSE) * sqrt(comlev / (comlev - 1)) * nsd/sqrt(sncol)
		}

		# 指定のあった指標を表に追加
		if(cind){
			bstat.info1 <- append(bstat.info1, nd.info)
			bstatist <- cbind(bstatist, "CIND-L" = mncol - ci.tval / sqrt(2), "CIND-U" = mncol + ci.tval / sqrt(2))
		}
		if(cin){
			bstat.info1 <- append(bstat.info1, n.info)
			bstatist <- cbind(bstatist, "CIN-L" = mncol - ci.tval, "CIN-U" = mncol + ci.tval)
		}
	}

	# マルチレベルモデルに基づく信頼区間の計算
	if(ciml){
		loadstate <- search()# この時点でのパッケージ呼び出し状態を記録
		pkchk <- library(lmerTest, logical.return = TRUE)# パッケージの呼び出し
		if(pkchk == FALSE) stop("Please install lmerTest package to use ciml option!!")# パッケージがなければストップ
		def.contr <- suppressWarnings(lmerControl()$checkControl)# lmerControlのデフォルト設定を保存
		options(lmerControl = list(check.nobs.vs.nlev = "ignore", check.nlev.gtr.1 = "ignore", check.nobs.vs.nRE = "ignore"))# 各種警告メッセージをオフ

		# モデル式の作成
		modeleq <- paste0("y ~ ", gsub(", ", " * ", toString(LETTERS[maxfact:1])))# 固定効果の指定
		if(withlen > 0){# 変量効果の指定；ランダム切片
			if(withlen == 1){
				randeq <- " + (1 | s)"
			}else{
				randeq <- paste0(" + (1 | s)", paste0(" + (1 | ", LETTERS[(betlen+1):maxfact], ":s)", collapse = ""))
			}
			modeleq <- paste0(modeleq, randeq)
		}

		# 推定と信頼区間の算出
		ml.model <- lmer(formula(modeleq), na.action = na.omit, REML = TRUE, data = dat)
		lscis <- ls_means(ml.model, which = paste0(LETTERS[maxfact:1], collapse = ":"), ddf = "Kenward-Roger")

		options(lmerControl = def.contr)# lmerControlの設定をもどす
		newstate <- search()# 現時点でのパッケージ呼び出し状態
		detlist <- newstate[!is.element(newstate, loadstate)]# 新たに呼び出したパッケージだけ選択
		detdummy <- sapply(detlist, function(x) detach(x, character.only = TRUE))# パッケージの解除

		# 指定のあった指標を表に追加
		bstat.info1 <- append(bstat.info1, "== Blouin-Riopelle's Multilevel-Based Confidence Intervals ==")
		bstatist <- cbind(bstatist, "CIML-L" = lscis$lower, "CIML-U" = lscis$upper)
	}

	# 記述統計量の表に信頼区間が追加されている場合は情報を追記
	if(ncol(bstatist) != (maxfact + 3)) bstat.info1 <- append(bstat.info1, paste0("== ", 100 * conf.level, "% confidence intervals are calculated. =="))
	ciset <- list("bstat.info1" = bstat.info1, "bstatist" = bstatist)

	# ペアワイズ信頼区間の計算
	if(cipaird || cipair){
		if(withlen == 0){# 被験者内要因がないとき（被験者間計画の場合）
			bstat.info2 <- "*** CAUTION! Pairwise confidence intervals are not suitable for between-subject designs. ***"
			ciset <- append(ciset, list("bstat.info2" = bstat.info2))
		}else{# 被験者内要因があるとき
			if(betlen == 0){# 被験者間要因がないとき（被験者内計画の場合）
				caldat <- list(dat)
				betlabels <- data.frame(row.names = 1:(comlev * (comlev - 1) / 2))
			}else{# １つ以上の被験者間要因があるとき（混合要因計画の場合）
				caldat <- split(dat, dat[, (maxfact+1-withlen):2])
				betlabels <- expand.grid(lapply((maxfact+1-withlen):2, function(x) levels(dat[, x])))
				betlabels <- betlabels[, order(betlen:1), drop = FALSE]# アルファベット順に列を並べ替え
				betlabels <- betlabels[rep(1:nrow(betlabels), each = comlev * (comlev - 1) / 2), , drop = FALSE]
				row.names(betlabels) <- NULL
				names(betlabels) <- factnames[1:betlen]
			}

			wdat <- lapply(caldat, function(x) data.frame(matrix(x$y[order(eval(parse(text = paste0("x[, ", c(1, (maxfact+1):(betlen+2)), "]"))))], length(x$y)/comlev, comlev)))# データをワイド形式のデータフレームに変換；tapplyによるアクセス順に対応させるための並べ替え
			ddat <- lapply(wdat, function(x) combn(comlev, 2, function(y) x[, y[1]] - x[, y[2]]))# ペアごとの差分得点
			pairbase <- lapply(ddat, function(x) data.frame("Diff" = colMeans(x), "n" = nrow(x), "S.E." = apply(x, 2, function(y) sd(y)/sqrt(length(y)))))# ペアワイズの差の平均，サンプルサイズ，標準誤差
			pairtab <- do.call(rbind, pairbase)
			rownames(pairtab) <- NULL

			crosslevels <- expand.grid(lapply((maxfact+1):(betlen+2), function(x) levels(dat[, x])), stringsAsFactors = FALSE)
			comblabels <- apply(crosslevels, 1, function(x) gsub(", ", ".", toString(x[withlen:1])))
			withlabels <- rep(combn(comlev, 2, function(x) gsub(", ", "-", toString(comblabels[x]))), times = prod(flev[pmin(1:betlen, betlen)]))

			pairtab <- cbind(betlabels, "Pairs" = withlabels, pairtab)
			ci.tval <- qt((1 - conf.level)/2, pairtab$"n" - 1, lower.tail = FALSE) * pairtab$"S.E."

			# 指定のあった指標を表に追加
			if(cipaird){
				bstat.info2 <- append(bstat.info2, "== Franz-Loftus's Difference-Adjusted Pairwise Confidence Intervals ==")
				pairtab <- cbind(pairtab, "CIPRD-L" = pairtab$Diff - ci.tval / sqrt(2), "CIPRD-U" = pairtab$Diff + ci.tval / sqrt(2))
			}
			if(cipair){
				bstat.info2 <- append(bstat.info2, "== Franz-Loftus's Pairwise Confidence Intervals ==")
				pairtab <- cbind(pairtab, "CIPR-L" = pairtab$Diff - ci.tval, "CIPR-U" = pairtab$Diff + ci.tval)
			}
			bstat.info2 <- append(bstat.info2, paste0("== ", 100 * conf.level, "% confidence intervals are calculated. =="))
			ciset <- append(ciset, list("bstat.info2" = bstat.info2, "pairtab" = pairtab))
		}
	}
	return(ciset)
}


# 信頼区間つきの棒グラフを作る関数
# ３要因までの計画に対応
# barmin：棒グラフｙ軸の下限値
ci.bars <- function(dat, design, factnames = NA, conf.level = 0.95, inn.tier = "cind", out.tier = NA, main = NULL, ylab = NULL, barmin = 0){
	maxfact <- nchar(design) - 1
	flev <- sapply(2:(maxfact + 1), function(x) nlevels(dat[, x]))# 各要因の水準数

	# factnamesが省略されているときは名前をつける
	if(anyNA(factnames)) factnames <- LETTERS[1:maxfact]

	# 信頼区間の計算
	eval(parse(text = paste0(c("cilmd", "cilm", "cind", "cin", "ciml"), "v <- FALSE")))
	eval(parse(text = paste0(inn.tier, "v <- TRUE")))
	eval(parse(text = paste0(out.tier, "v <- TRUE")))
	baseresults <- ci.calc(dat, design, factnames = factnames, conf.level = conf.level, cilmd = cilmdv, cilm = cilmv, cind = cindv, cin = cinv, ciml = cimlv)
	bstatist <- baseresults$bstatist

	# グラフィックデバイスを開く
	if(sum(grep("mac", .Platform)) != 0){# Macの場合
		quartz(title = paste0("Bar Graph for ", design, "-Type Design"))
	}else{# その他のOSの場合
		x11(title = paste0("Bar Graph for ", design, "-Type Design"))
	}

	# グラフパラメータの設定
	preset <- par(no.readonly = TRUE)
	par(lwd = 1.5, cex = 1.8, plt = c(0.2, 0.7, 0.2, 0.87), mgp = c(2.5, 0.5, 0), xpd = TRUE)
	if(is.na(out.tier) == TRUE){# 外側エラーバーがない場合
		mMax <- max(bstatist[, paste0(toupper(inn.tier), "-U")])# 最大値
		mMin <- min(bstatist[, paste0(toupper(inn.tier), "-L")])# 最小値
	}else{# 外側エラーバーがある場合
		mMax <- max(bstatist[, paste0(toupper(out.tier), "-U")])# 最大値
		mMin <- min(bstatist[, paste0(toupper(out.tier), "-L")])# 最小値
	}
	mcoef <- 10^(nchar(abs(round(mMax)))-2)
	betbars <- rep(c(1, rep(0, flev[maxfact] - 1)), prod(flev)/flev[maxfact])# バーの間隔
	if(length(flev) == 3){
		gdivs <- (1:prod(flev))[(1:prod(flev) %% (prod(flev)/flev[1])) == 0]
		gdivs <- gdivs[-length(gdivs)]
		betbars[gdivs + 1] <- 2
	}
	barcolor <- gray(0.5/flev[maxfact] * flev[maxfact]:1 + 0.45)

	# グラフの描画
	barplot(matrix(bstatist$Mean, prod(flev)/flev[maxfact], flev[maxfact]), 
		las = 2, space = betbars, tcl = 0.25, ylab = ylab, 
		ylim = c(pmin(barmin, floor(mMin/mcoef) * mcoef), ceiling(mMax/mcoef) * mcoef), 
		xlim = c(0.5, length(betbars) + (prod(flev)/flev[maxfact])^(1 * (sum(betbars) != 1)) + 1 * sum(betbars == 2)), 
		col = barcolor, 
		xpd = FALSE, beside = TRUE)
	box(bty = "l")# ｘ軸の線を引く
	title(main, line = 0.8)# タイトルを書く

	# ｘ軸のラベル
	if(maxfact == 1){# １要因のときは水準名の代わりに要因名を表示する
		xlabpos <- flev/2 + 1
		text(xlabpos, 0, pos = 1, offset = 1, labels = factnames)
	}else{
		for(i in pmax(maxfact - 1, 1):1){# ｘ軸に水準名を表示する
			xlabframe <- unique(bstatist[, 1:i, drop = FALSE])
			xtf <- betbars >= (maxfact - i)
			xtf[1] <- TRUE
			xcue <- (1:length(betbars))[xtf] + mean(1:(prod(flev)/prod(flev[1:i]))) - 1
			xlabpos <- cumsum(c(0.5, betbars[-1]))[xcue] + xcue# ｘ軸ラベルの位置
			text(xlabpos, pmin(barmin, floor(mMin/mcoef) * mcoef), pos = 1, offset = 1.2 * pmax(maxfact - i, 1) - 0.4, labels = xlabframe[, i])
		}
	}

	# 凡例
	legend(length(betbars) + sum(betbars) + 0.5, ceiling(mMax/mcoef) * mcoef, 
		legend = levels(bstatist[, maxfact]), cex = 0.9, x.intersp = 0.6, y.intersp = 1, 
		pch = 22, pt.bg = barcolor, pt.cex = 1.6, # 条件の別を表すマークの設定
		bty = "n")

	# エラーバー
	if(is.na(out.tier) == FALSE){# 外側エラーバーが指定されている場合
		arrows(cumsum(betbars) + 1:prod(flev) - 0.5, bstatist[, paste0(toupper(out.tier), "-L")], # 外側エラーバー
			cumsum(betbars) + 1:prod(flev) - 0.5, bstatist[, paste0(toupper(out.tier), "-U")], 
			angle = 90, length = 0.04, code = 3, lwd = 2)
	}
	arrows(cumsum(betbars) + 1:prod(flev) - 0.5, bstatist[, paste0(toupper(inn.tier), "-L")], # 内側エラーバー
		cumsum(betbars) + 1:prod(flev) - 0.5, bstatist[, paste0(toupper(inn.tier), "-U")], 
		angle = 90, length = 0.06, code = 3, lwd = 2)
	par(preset)# グラフパラメータの設定を元に戻す
}


# 文字列中のすべての要素を含む文字列をマッチングする関数
# grepとの違いは“A:C”などの文字列を照合パターンとした場合に“A:B:C”のように間に別の文字を挟んだ文字列もマッチと判定する点
# 照合パターンが１文字の場合はgrepと同じ結果を返す
elematch <- function(Mstrings, stex){
	# マッチングする文字列を分解して，それぞれgrep関数を適用
	matchlist <- lapply(strsplit(Mstrings, "")[[1]], function(x) grep(x, stex))

	# 文字列の各要素とマッチした値の共通部分のみ取り出す
	buffer <- matchlist[[1]]

	# 文字列が１文字のときはgrepの結果をそのまま返す
	if(length(matchlist) != 1){
		for(i in 2:length(matchlist)){
			buffer <- buffer[is.element(buffer, matchlist[[i]])]
		}
	}
	return(buffer)
}


# ベクトルの組み合わせを作る関数
# expand.gridと同様の組み合わせを作る；結果をmatrix型で返す
expand.gmatrix <- function(...){
	elem <- list(...)
	if(is.list(elem[[1]])) elem <- unlist(elem, recursive = FALSE)
	elemsize <- sapply(elem, length)
	rcue <- c(1, cumprod(elemsize)[-length(elemsize)])
	rlev <- cumprod(elemsize)
	levmax <- prod(elemsize)
	expmat <- mapply(function(w, x, y, z) rep.int(rep.int(w, rep.int(y, x)), prod(elemsize)/z), elem, elemsize, rcue, rlev)
	return(expmat)
}


# 有意水準に合わせて記号を表示する関数
sig.sign <- function(pvalue){
	ifelse(is.na(pvalue), "", 
	ifelse(pvalue < 0.001, "***", 
	ifelse(pvalue < 0.01, "**", 
	ifelse(pvalue < 0.05, "*", 
	ifelse(pvalue < 0.10, "+", "ns")))))
}


# Greenhouse-GeisserとHuynh-Feldtのイプシロンを計算する関数
# 被験者内要因を含まない計画を投入すると適切に動作しないので注意
epsilon.calc <- function(dat, design, mau = FALSE, har = FALSE, iga = FALSE, ciga = FALSE, lb = FALSE, gg = FALSE, hf = FALSE, 
	cm = FALSE, autov = NULL, flev = NULL, cellN = NULL, esboot = FALSE){
	maxfact <- nchar(design) - 1# 実験計画全体における要因数
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数
	if(is.null(flev)) flev <- sapply(2:(maxfact+1), function(x) nlevels(dat[, x]))# 各要因の水準数
	if(is.null(cellN)) cellN <- length(unique(dat$s))# 被験者間要因をつぶしての全被験者の数を取得

	# 被験者内要因の特定
	replabel <- (maxfact - withlen + 2):(maxfact + 1)
	repnum <- sort(replabel, decreasing = TRUE)# 後の方の要因のラベルを先に並べる
	repmat <- flev[repnum - 1]# 各要因の水準数をベクトル化
	rl <- prod(repmat)# 全被験者内要因の組み合わせ水準数を取得

	# データフレームを分割し，共分散行列を作る
	if(betlen == 0){# 被験者間要因がないときはデータフレームを分割しない
		othlabel <- 1
		ol <- 1
		othN <- cellN# 被験者間要因がないときはcellNと同じ値を代入
		covmatrices <- list(cov(do.call(cbind, split(dat$y, dat[, repnum]))))
	}else{# 被験者間要因の組み合わせ水準ごとにデータフレームを分割
		# 被験者間要因の特定
		othlabel <- 1:betlen + 1
		othnum <- sort(othlabel, decreasing = TRUE)# 後の方の要因のラベルを先に並べる
		othmat <- flev[othnum - 1]# 各要因の水準数をベクトル化
		ol <- prod(othmat)# 全被験者間要因の組み合わせ水準数
		sdat <- split(dat$y, dat[, othnum])
		othN <- sapply(sdat, length) / rl# 被験者間要因の各組み合わせにおける被験者数をベクトル化
		covmatrices <- lapply(sdat, function(x) cov(matrix(x, ncol = rl)))
	}

	# 複数の共分散行列をプール
	tm <- Reduce(f = "+", x = lapply(1:ol, function(w) (othN[w] - 1) * covmatrices[[w]])) / (cellN - ol)

	# 正規直交対比行列を作る；被験者内要因の数に合わせて異なるパターンを得る
	combmat <- expand.gmatrix(lapply(repmat - 1, function(x) 0:x))[, rev(1:withlen), drop = FALSE]# 列が１のときにベクトルに変換されないようにdrop = FALSEを使う
	cuemat <- cbind(1:nrow(combmat), colSums(t(combmat != 0) * 10^((withlen-1):0)), rowSums(combmat != 0))
	ortho.ord <- unlist(lapply(0:withlen, function(x) cuemat[cuemat[, 3] == x, 1][sort.list(cuemat[cuemat[, 3] == x, 2], decreasing = TRUE)]))
	ortho.helm <- Reduce(f = kronecker, x = lapply(flev[replabel - 1], function(w) cbind(1, contr.helmert(w))))
	ortho.helm <- ortho.helm[, ortho.ord]# 解釈しやすい順に並べ替え
	ortho.coef <- t(ortho.helm[, 2:rl, drop = FALSE])# 直交対比のパターンのみを取り出す；行が１のときにベクトルに変換されないようにdrop = FALSEを使う
	ortho.denomi <- rowSums(ortho.coef^2)^(1/2)

	# パターンを直交対比行列にする
	orthoM <- ortho.coef / ortho.denomi

	# 被験者内要因の数によって処理を変更する
	if(withlen == 1){# 被験者内要因が１つのとき
		matdivider <- flev[replabel - 1] - 1# 正規直交行列を分割する際の行数
		effect.name <- paste0(names(dat)[replabel], collapse = ":")# 効果のラベルを作る
		ss.name <- paste0(paste0(c("s", LETTERS[othlabel - 1]), collapse = ":"), ":", effect.name)

		# 正規直交対比行列関連の処理
		seportM <- list(orthoM)
		totalM <- seportM
		gmd <- matdivider
		otoM <- orthoM %*% tm %*% t(orthoM)# 共分散行列と正規直交対比行列をかける
		ss.er <- (cellN - ol) * sum(diag(otoM))
		df.er <- (cellN - ol) * nrow(otoM)
		otoM <- list(otoM)
	}else{# 被験者内要因が複数あるとき
		ctlframe <- unlist(lapply(1:withlen, function(y) combn(replabel, y, function(x) x, simplify = FALSE)), recursive = FALSE)
		matdivider <- unlist(lapply(ctlframe, function(x) prod(flev[x - 1] - 1)))# 正規直交行列を分割する際の行数
		effect.name <- unlist(lapply(ctlframe, function(x) paste0(names(dat)[x], collapse = ":")))# 効果のラベルを作る
		ss.name <- paste0(paste0(c("s", LETTERS[othlabel - 1]), collapse = ":"), ":", effect.name)

#		<- apply(combmat, 1, function(x) paste0(LETTERS[(1:maxfact)[rev(x) == 1]], collapse = ":"))

		# ラベルの追加
		effect.name <- c("Global", effect.name)

		# 正規直交対比行列を被験者内要因の水準数によって分割
		divpoint <- mapply(function(x, y) seq(x, y), cumsum(matdivider) - (matdivider - 1), cumsum(matdivider), SIMPLIFY = FALSE)
		seportM <- lapply(divpoint, function(x) orthoM[x, , drop = FALSE])
		totalM <- c(list(orthoM), seportM)
		gmd <- c(rl - 1, matdivider)
		otoM <- lapply(totalM, function(x) x %*% tm %*% t(x))# 共分散行列と正規直交対比行列をかける
		ss.er <- sapply(otoM, function(x) (cellN - ol) * sum(diag(x)))[-1]
		df.er <- sapply(otoM, function(x) (cellN - ol) * nrow(x))[-1]
	}
	ss.errs <- matrix(c(ss.er, df.er), ncol = 2, dimnames = list(ss.name, c("ss.col", "df.col")))

	# イプシロンを計算する
	LB.ep <- 1 / gmd
	GG.ep <- sapply(otoM, function(x) sum(diag(x))^2 / (nrow(x) * sum(x^2)))
	HF.ep <- ((cellN - ol + 1) * gmd * GG.ep - 2) / (gmd * (cellN - ol - gmd * GG.ep))# Lecoutre（1991）の修正
	va <- (cellN - ol - 1) + (cellN - ol) * (cellN - ol - 1) / 2
	CM.ep <- pmax(LB.ep, HF.ep * (va - 2) * (va - 4) / va^2)

	# 球面性検定の実施
	if(esboot){# ブートストラップ計算の場合はスキップ
		if(lb){
			sph.ep <- LB.ep[min(withlen, 2):length(gmd)]
		}else if(gg){
			sph.ep <- GG.ep[min(withlen, 2):length(gmd)]
		}else if(hf){
			sph.ep <- HF.ep[min(withlen, 2):length(gmd)]
		}else if(cm){
			sph.ep <- CM.ep[min(withlen, 2):length(gmd)]
		}else if(!is.null(autov)){
			sph.ep <- GG.ep[min(withlen, 2):length(gmd)]
			sph.ep[autov] <- 1
		}else{
			sph.ep <- rep(1, nrow(ss.errs))
		}
		return(list("ss.errs" = ss.errs, "sph.ep" = sph.ep))
	}else{
		if(mau){# Mauchlyの球面性検定
			# プロンプトの準備
			epsi.info1 <- paste0("== Mauchly's Sphericity Test and Epsilons ==")
			lamlab <- "W"
			eps.Lambda <- sapply(otoM, function(x) det(x) / (sum(diag(x)) / nrow(x))^nrow(x))
			eps.m <- 1 - (2 * gmd^2 + gmd + 2) / (6 * (cellN - ol) * gmd)
			epsChi <- -(cellN - ol) * eps.m * log(eps.Lambda)

			if(any(min(othN) < gmd)){# 各群の被験者数が正規直交対比行列の行数を下回るときは妥当なカイ二乗値を計算できない
				epsChi[min(othN) < gmd] <- NA
				eps.Lambda[min(othN) < gmd] <- NA
				epsi.info1 <- paste0(epsi.info1, "\n", 
					"*** CAUTION! The test of SPHERICITY is INVALID because of small sample size. ***", "\n", 
					"*** The minimum sample size for valid computation is N = ", max(gmd) + 1, " at each group. ***")
			}

			eps.df <- gmd * (gmd + 1)/ 2 - 1
			eps.p1 <- pchisq(epsChi, ifelse(eps.df == 0, NA, eps.df), lower.tail = FALSE)
			eps.p2 <- pchisq(epsChi, eps.df + 4, lower.tail = FALSE)
			eps.w2 <- (gmd + 2) * (gmd - 1) * (gmd - 2) * (2 * gmd^3 + 6 * gmd^2 + 3 * gmd + 2) / (288 * gmd^2 * (cellN - ol)^2 * eps.m^2)
			eps.p <- eps.p1 + eps.w2 * (eps.p2 - eps.p1)
		}else if(har){# Harrisの多標本球面性検定
			# プロンプトの準備
			epsi.info1 <- paste0("== Harris's Multisample Sphericity Test and Epsilons ==")
			lamlab <- "h_hat"
			proA <- lapply(totalM, function(x) lapply(covmatrices, function(y) x %*% y %*% t(x)))
			epsTr <- lapply(proA, function(y) sapply(y, function(x) sum(diag(x))))
			epsSq <- lapply(proA, function(y) sapply(y, function(x) sum(diag(x %*% x))))
			eps.Lambda <- sapply(1:length(proA), function(x) sum((othN - 1) * epsTr[[x]])^2 / sum((othN - 1) * epsSq[[x]]))
			epsChi <- pmax(0, ((cellN - ol) * gmd / 2) * ((cellN - ol) * gmd / eps.Lambda - 1))# 負の値は０にそろえる

			if(any(min(othN) < gmd)){# 各群の被験者数が正規直交対比行列の行数を下回るときは妥当なカイ二乗値を計算できない
				epsChi[min(othN) < gmd] <- NA
				eps.Lambda[min(othN) < gmd] <- NA
				epsi.info1 <- paste0(epsi.info1, "\n", 
					"*** CAUTION! The test of SPHERICITY is INVALID because of small sample size. ***", "\n", 
					"*** The minimum sample size for valid computation is N = ", max(gmd) + 1, " at each group. ***")
			}

			eps.df <- ((ol * gmd * (gmd + 1)) / 2) - 1
			eps.p0 <- pchisq(epsChi, ifelse(eps.df == 0, NA, eps.df), lower.tail = FALSE)
			eps.p6 <- pchisq(epsChi, eps.df + 6, lower.tail = FALSE)
			eps.p4 <- pchisq(epsChi, eps.df + 4, lower.tail = FALSE)
			eps.p2 <- pchisq(epsChi, eps.df + 2, lower.tail = FALSE)
			eps.p <- pmax(0, eps.p0 + ((gmd^3 + 3 * gmd^2 - 8 * gmd - 12 - 200/gmd) * eps.p6 / 12 
				+ (-2 * gmd^3 - 5 * gmd^2 + 7 * gmd + 12 + 420/gmd) * eps.p4 / 8 
				+ (gmd^3 + 2 * gmd^2 - gmd - 2 - 216/gmd) * eps.p2 / 4 
				+ (-2 * gmd^3 - 3 * gmd^2 + gmd + 436/gmd) * eps.p0 / 24 
				) / (cellN - ol))
		}else{# Mendozaの多標本球面性検定
			# プロンプトの準備
			epsi.info1 <- paste0("== Mendoza's Multisample Sphericity Test and Epsilons ==")
			lamlab <- "Lambda"
			proA <- lapply(totalM, function(x) lapply(1:ol, function(y) x %*% (othN[y] * covmatrices[[y]]) %*% t(x)))
			eps.m <- 1 - ((((cellN-ol) * gmd^2 * (gmd + 1) * (2 * gmd + 1) - (2*(cellN-ol) * gmd^2)) * 
				sum(1/(othN-1)) - 4) / (6 * (cellN-ol) * gmd * (ol * gmd * (gmd + 1) - 2)))
			eps.m[is.nan(eps.m)] <- 0# NaNが出たところには０を代入

			menL1 <- log(cellN-ol) * ((cellN-ol)*(gmd)/2) - sapply(gmd, function(x) sum(log(othN-1) * ((othN-1) * x / 2)))
			menL2 <- sapply(proA, function(y) sum(sapply(y, function(x) determinant(x, logarithm = TRUE)$modulus[1]) * (othN-1)/2))
			menL3 <- sapply(proA, function(y) sum(diag(Reduce(f = "+", x = y)/nrow(y[[1]]))))
			menL3 <- log(ifelse(menL3 < 0, NA, menL3)) * ((cellN-ol) * gmd / 2)# トレースが負のときは対数に変換できないのでNAに置き換え
			menL <- menL1 + menL2 - menL3
			epsChi <- - 2 * eps.m * menL
			eps.Lambda <- exp(menL)

			if(any(min(othN) < gmd)){# 各群の被験者数が正規直交対比行列の行数を下回るときは妥当なカイ二乗値を計算できない
				epsChi[min(othN) < gmd] <- NA
				eps.Lambda[min(othN) < gmd] <- NA
				epsi.info1 <- paste0(epsi.info1, "\n", 
					"*** CAUTION! The test of SPHERICITY is INVALID because of small sample size. ***", "\n", 
					"*** The minimum sample size for valid computation is N = ", max(gmd) + 1, " at each group. ***")
			}

			eps.df <- ol * gmd * (gmd + 1) / 2 - 1
			eps.p1 <- pchisq(epsChi, ifelse(eps.df == 0, NA, eps.df), lower.tail = FALSE)
			eps.p2 <- pchisq(epsChi, eps.df + 4, lower.tail = FALSE)
			eps.w2 <- (gmd + 2) * (gmd - 1) * (gmd - 2) * (2 * gmd^3 + 6 * gmd^2 + 3 * gmd + 2) / (288 * gmd^2 * (cellN - ol)^2 * eps.m^2)
			eps.p <- eps.p1 + eps.w2 * (eps.p2 - eps.p1)
		}

		# 結果をデータフレームにまとめる
		sig.mark <- sig.sign(eps.p)
		epsitab <- data.frame("Effect" = effect.name, "Dummy" = eps.Lambda, "approx.Chi" = epsChi, "df" = eps.df, 
			"p" = eps.p, "sig.mark" = sig.mark, "LB" = LB.ep, "GG" = GG.ep, "HF" = HF.ep, "CM" = CM.ep)
		names(epsitab)[2] <- lamlab# ラベルを検定方法に応じたものに変更
	}

	# オプション；IGAのための統計量を計算
	if(iga || ciga){
		# HuynhのImproved General Approximate Test
		wt.name <- effect.name[effect.name != "Global"]
		wtlen <- length(wt.name)
		proSj <- lapply(seportM, function(y) lapply(covmatrices, function(x) y %*% x %*% t(y)))
		trDj <- lapply(proSj, function(y) sapply(y, function(x) sum(diag(x))))
		trDj2 <- lapply(proSj, function(y) sapply(y, function(x) sum(diag(x %*% x))))

		ldat <- cbind(1, dat[, -1])
		sdat <- split(dat, ldat[, cummin((betlen+1):2)])
		lxn <- lapply(sdat, function(x) matrix(x$y[order(eval(parse(text = paste0("x[, ", c(1, (maxfact+1):(betlen+2)), "]"))))], length(x$y)/rl, rl))
		ssize <- sapply(sdat, function(x) nrow(x)/rl)# セルごとのサンプルサイズ
		sscp <- lapply(lxn, function(x) t(x) %*% (diag(nrow(x)) - 1/nrow(x)) %*% x)
		vcv <- lapply(1:ol, function(x) sscp[[x]]/(ssize[x]-1))
		vcdng <- lapply(1:ol, function(x) vcv[[x]]/ssize[x])
		zeromat <- list(matrix(0, rl, rl))
		iga.Sigstr <- do.call(rbind, lapply(1:ol, function(x) do.call(cbind, ifelse(1:ol == x, vcdng[x], zeromat))))

		if(ol == 1){# 被験者間要因がない場合
			invXX <- diag(1)/ssize
			cmat <- list(matrix(1))# 被験者内要因のみの組み合わせに相当する部分のデザイン行列
			iga.eta <- mapply(function(y, z) sum((othN - 1)^3 / ((othN + 1) * (othN - 2)) * (othN * y^2 - 2 * z)), trDj, trDj2)
			bw.df <- 1

			iga.filler <- NULL
			iga.letfill <- NULL
			iga.label <- effect.name
		}else{# １つ以上の被験者間要因がある場合
			invXX <- diag(1/ssize)
			factcomb <- expand.gmatrix(replicate(betlen, list(0:1)))[-1, , drop = FALSE]# 全組み合わせのパターン
			comblabel <- apply(factcomb, 1, function(x) paste0(LETTERS[1:betlen][x == 1], collapse = ":"))# 効果名のラベル
			names(comblabel) <- NULL
			labord <- order(nchar(comblabel), comblabel)
			factcomb <- factcomb[labord, , drop = FALSE]# 行名に対応するよう組み合わせのパターンを並べ替え
			comblabel <- comblabel[labord]# 効果名のラベルを並べ替え
			row.names(factcomb) <- comblabel# 組み合わせのパターンに行名をつける
			rmat <- lapply(flev, function(x) cbind(1, -1 * diag(x - 1)))# 行列パターン；効果に組み入れる場合に使う
			rvec <- lapply(flev, function(x) array(1, c(1, x)))# ベクトルパターン；効果に組み入れない場合に使う
			doubler <- list(rvec, rmat)
			cmat <- lapply(1:nrow(factcomb), function(w) Reduce(f = kronecker, x = lapply(1:betlen, function(y) 
				doubler[[c(factcomb[w, y] + 1, y)]])))# 被験者間要因のデザイン行列
			cmat <- c(list(array(rep(1, ol), c(1, ol))), cmat)# 被験者内要因のみの組み合わせに相当する部分のデザイン行列
			iga.eta <- mapply(function(y, z) sum((othN - 1)^3 / ((othN + 1) * (othN - 2)) * (othN * y^2 - 2 * z)) + 
				2 * sum(combn(ol, 2, function(x) prod((othN[x] - 1) * y[x]))), trDj, trDj2)
			bw.df <- sapply(cmat, nrow)

			iga.filler <- rep(NA, wtlen * (length(bw.df) - 1))
			iga.letfill <- rep("", wtlen * (length(bw.df) - 1))
			iga.label <- c(setdiff(effect.name, wt.name), unlist(lapply(wt.name, function(x) c(x, paste(comblabel, x, sep = ":")))))
		}

		iga.G <- unlist(lapply(seportM, function(w) lapply(cmat, function(x) t(x) %*% 
			qr.coef(qr(x %*% invXX %*% t(x), LAPACK = TRUE), diag(nrow(x))) %*% x %x% (t(w) %*% w))), recursive = FALSE)
		rs <- sapply(seportM, function(w) sum((ssize-1) * sapply(vcv, function(x) sum(diag(w %*% x %*% t(w))))))
		iga.GS <- lapply(iga.G, function(x) x %*% iga.Sigstr)
		iga.h0 <- sapply(iga.GS, function(x) sum(diag(x))^2) / sapply(iga.GS, function(x) sum(diag(x %*% x)))
		iga.m <- sapply(iga.GS, function(x) ((cellN - ol) * sum(diag(x)))) / as.vector(tcrossprod(bw.df, rs))
		iga.h <- ifelse(iga.h0 == 1, 1, (bw.df * (cellN * iga.h0 - 2 * bw.df)) / ((cellN - ol) * bw.df - iga.h0))
		iga.sigma <- mapply(function(x, y) sum((othN - 1)^2 / ((othN + 1) * (othN - 2)) * ((othN - 1) * y - x^2)), trDj, trDj2)
		iga.e <- iga.eta / iga.sigma

		# Algina-LecoutreのCorrected Improved General Approximation Testのための指標
		bw.dfr <- rep(bw.df, each = length(seportM))
		iga.al <- ifelse(iga.h0 == 1, 1, (bw.dfr * ((cellN - ol + 1) * iga.h0 - 2 * bw.df)) / ((cellN - ol) * bw.dfr - iga.h0))

		# 結果をデータフレームにまとめる
		bwlen <- length(bw.df)
		iga.e <- rep(iga.e, each = bwlen)
		if(withlen == 1){# 被験者内要因が１つの場合
			iga.ord <- order(c(seq(from = 1, by = bwlen, length.out = wtlen) - 0:(wtlen-1), 
				seq(from = 1, length.out = wtlen * (bwlen - 1))))
		}else{# 被験者内要因が２つ以上の場合
			iga.m <- c(NA, iga.m)
			iga.h <- c(NA, iga.h)
			iga.al <- c(NA, iga.al)
			iga.e <- c(NA, iga.e)
			iga.ord <- c(0, order(c(seq(from = 1, by = bwlen, length.out = wtlen) - 0:(wtlen-1), 
				seq(from = 1, length.out = wtlen * (bwlen - 1))))) + 1
		}
		if(iga){# IGA
			epsi.info1 <- sub("Epsilons", "Estimates for IGA", epsi.info1)
			epsitab <- data.frame("Effect" = iga.label, "Dummy" = c(eps.Lambda, iga.filler)[iga.ord], 
				"approx.Chi" = c(epsChi, iga.filler)[iga.ord], "df" = c(eps.df, iga.filler)[iga.ord], 
				"p" = c(eps.p, iga.filler)[iga.ord], "sig.mark" = c(sig.mark, iga.letfill)[iga.ord], 
				"multiplier" = iga.m, "adj.ndf" = iga.h, "adj.ddf" = iga.e)
		}else{# CIGA
			epsi.info1 <- sub("Epsilons", "Estimates for CIGA", epsi.info1)
			epsitab <- data.frame("Effect" = iga.label, "Dummy" = c(eps.Lambda, iga.filler)[iga.ord], 
				"approx.Chi" = c(epsChi, iga.filler)[iga.ord], "df" = c(eps.df, iga.filler)[iga.ord], 
				"p" = c(eps.p, iga.filler)[iga.ord], "sig.mark" = c(sig.mark, iga.letfill)[iga.ord], 
				"multiplier" = iga.m, "adj.ndf" = iga.al, "adj.ddf" = iga.e)
		}
		names(epsitab)[2] <- lamlab# ラベルを検定方法に応じたものに変更
	}

	return(list("epsi.info1" = epsi.info1, "epsitab" = epsitab, "ss.errs" = ss.errs))
}


# 平方和を計算する関数
ss.calc <- function(dat, design, ss.errs = NA, type2 = FALSE, dmat = NULL, flev = NULL, cellN = NULL){
	maxfact <- nchar(design) - 1# 実験計画全体における要因数
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数
	if(is.null(flev)) flev <- sapply(2:(maxfact+1), function(x) nlevels(dat[, x]))# 各要因の水準数
	if(is.null(cellN)) cellN <- length(unique(dat$s))
	ol <- prod(flev[min(1, betlen):betlen])# 全被験者間要因の組み合わせ水準数を取得；被験者間要因がないときには１

	eff.elem <- unlist(lapply(1:maxfact, function(y) combn(maxfact, y, function(x) paste0(LETTERS[x], collapse = ":"))))
	eff.modeleq <- paste0("~ ", paste(eff.elem, collapse = " + "))

	def.contr <- options("contrasts")[[1]]# contrastsのデフォルト設定を保存
	options(contrasts = c("contr.sum", "contr.poly"))# 設定を変更
	if(is.null(dmat)) dmat <- model.matrix(as.formula(eff.modeleq), dat)# デザイン行列を作る

	# 計画行列とデータを統合する
	exmat <- cbind(dmat, dat$y)# 拡大行列を作る
	promat <- crossprod(exmat)# 拡大行列の積和行列
	endline <- nrow(promat)# 積和行列の列数

	# 各効果に対応する計画行列の列（行）番号を得る
	sepcol <- attr(dmat, "assign")# 計画行列からピボットを表すベクトルを取り出す
	pivot.col <- lapply(1:max(sepcol), function(x) (1:length(sepcol))[sepcol == x])# 各効果を表現する列の番号
	df.col <- sapply(pivot.col, function(x) length(x))

	if(type2){# 線形モデルを用いてタイプⅡ平方和を計算する
		# 各効果の平方和の計算
		# 各モデルのための部分行列を選択
		names(pivot.col) <- eff.elem
		ss.line1 <- lapply(eff.elem, function(x) c(1, unlist(pivot.col[match(x, names(pivot.col))]), unlist(pivot.col[-elematch(x, names(pivot.col))])))
		ss.line2 <- lapply(eff.elem, function(x) c(1, unlist(pivot.col[-elematch(x, names(pivot.col))])))

		# 各モデルの最小二乗解を得てもとのベクトルにかけたものの和を取る
		ss.base1 <- sapply(ss.line1, function(x) colSums(qr.coef(qr(promat[x, x], LAPACK = TRUE), promat[x, endline]) * promat[x, endline, drop = FALSE]))
		ss.base2 <- sapply(ss.line2, function(x) colSums(qr.coef(qr(promat[x, x], LAPACK = TRUE), promat[x, endline]) * promat[x, endline, drop = FALSE]))

		# 各効果を含むモデルと含まないモデルの差分を取る
		ss.all <- ss.base1 - ss.base2
	}else{# 線形モデルを用いてタイプⅢ平方和を計算する
		# 各効果の平方和の計算
		eff.line <- c(1, unlist(pivot.col))

		# 各モデルのための部分行列を選択
		ss.line <- lapply(pivot.col, function(x) eff.line[-x])

		# 各モデルの最小二乗解を得てもとのベクトルにかけたものを合計
		ss.eff <- sum(qr.coef(qr(promat[eff.line, eff.line], LAPACK = TRUE), promat[eff.line, endline]) * promat[eff.line, endline, drop = FALSE])
		ss.base <- sapply(ss.line, function(x) sum(qr.coef(qr(promat[x, x], LAPACK = TRUE), promat[x, endline]) * promat[x, endline, drop = FALSE]))

		# 各効果を含むモデルと含まないモデルの差分を取る
		ss.all <- ss.eff - ss.base
	}

	# 全体平方和の計算
	ss.T <- promat[endline, endline] - qr.coef(qr(promat[1, 1], LAPACK = TRUE), promat[1, endline]) * promat[1, endline]

	# 誤差平方和の計算
	ss.Er <- promat[endline, endline] - sum(qr.coef(qr(promat[1:(endline-1), 1:(endline-1)], LAPACK = TRUE), promat[1:(endline-1), endline]) * promat[1:(endline-1), endline])

	ss.results <- matrix(c(ss.all, ss.Er, ss.T, df.col, cellN - ol, nrow(dat) - 1), ncol = 2, 
		dimnames = list(c(eff.elem, "Error", "Total"), c("ss.col", "df.col")))

	if(!anyNA(ss.errs)){# 反復測定要因がある場合
		ss.res <- ss.Er - sum(ss.errs[, 1], na.rm = TRUE)
		res.name <- paste0(strsplit(paste0("s", strsplit(design, "s")[[1]][1]), "")[[1]], collapse = ":")
		res.er <- cbind(ss.res, cellN - ol)
		row.names(res.er) <- res.name

		bst <- sum(choose(betlen, 1:betlen)) * (betlen != 0)# 被験者間要因の組み合わせ数
		wst <- sum(choose(withlen, 1:withlen))# 被験者内要因の組み合わせ数
		er.pos <- cumsum(c(bst+1, rep(bst+2, wst)))# 各誤差項の位置

		if(betlen == 0){# 被験者内計画の場合
			ss.pos <- 1:wst
		}else{# 混合要因計画の場合
			ss.fig <- rbind(1:(nrow(ss.results) - 2), do.call(rbind, lapply(LETTERS[1:maxfact], function(x) 1 * grepl(x, eff.elem))))
			withsize <- 2^(0:(withlen-1))
			withbox <- do.call(cbind, lapply(withsize, function(x) rep.int(rep.int(0:1, rep.int(x, 2)), max(withsize)/x)))[-1, , drop = FALSE]
			withbox <- withbox[order(rowSums(withbox)), , drop = FALSE]
			ss.pos <- c(ss.fig[1, colSums(ss.fig[(maxfact-withlen+1):maxfact + 1, , drop = FALSE]) == 0], unlist(lapply(1:nrow(withbox), function(x) ss.fig[1, colSums(ss.fig[(maxfact-withlen+1):maxfact + 1, , drop = FALSE] == withbox[x, ]) == withlen])))
		}

		ss.results <- rbind(ss.results[-(nrow(ss.results)-1), ], res.er, ss.errs)# 誤差平方和を連結
		ss.order <- order(c((1:(nrow(ss.results)-2))[-er.pos][order(ss.pos)], nrow(ss.results), er.pos))# 並べ替え用のベクトル
		ss.results <- ss.results[ss.order, ]
	}

	options(contrasts = def.contr)# contrastsの設定をもどす
	return(list("ss.results" = ss.results, "dmat" = dmat))
}


# 非心F分布のパラメータの信頼限界を算出する関数
# conf.limits.ncf（MBESSパッケージ）との違いは，ベクトルを入力として受け取れる点
# Kelley, K. (2007). Confidence intervals for standardized effect sizes: Theory, application, and implementation. Journal of Statistical Software, 20, 8.
qlambda.ncf <- function (Fratio, ndf, ddf, conf.level = 0.95, tol = 1e-09, JmpProp = 0.1){
	lwalp <- (1 - conf.level)/2
	upalp <- (1 - conf.level)/2
	Fratio[Fratio == Inf] <- 0

	# 下限の算出
	Llim <- c()# 非心パラメータを保存するベクトル
	Lbase <- qf(p = lwalp * 5e-04, df1 = ndf, df2 = ddf)
	delta <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Lbase) - (1 - lwalp)
	if(any(delta < 0)){# 解を出せない箇所がある場合
		Lbase[pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = 0) < (1 - lwalp)] <- 1e-08
		if(any(pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Lbase) < (1 - lwalp))){
			Lbase[pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Lbase) < (1 - lwalp)] <- NA
			Llim[delta < 0] <- NA
		}
	}

	if(!all(is.na(Lbase))){# １つ以上の解が出せる場合
		Lvec <- c()
		L1 <- Lbase
		L2 <- Lbase
		repeat{
			L2 <- L1 * (1 + JmpProp)
			delta <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = L2) - (1 - lwalp)
			if(any(delta <= tol, na.rm = TRUE)){
				tpos <- grep(TRUE, delta <= tol)
				Lvec[tpos] <- L2[tpos]
				L2[tpos] <- NA
				delta[tpos] <- NA
				if(all(is.na(delta))) break
			}
			L1 <- L2
		}
		Lguidel <- Lvec / (1 + JmpProp)
		Lguider <- Lvec
		Lmid <- (Lguidel + Lguider)/2

		delta <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Lmid) - (1 - lwalp)
		repeat{
			if(any(abs(delta) <= tol, na.rm = TRUE)){
				dpos <- grep(TRUE, delta <= tol)
				Llim[dpos] <- Lmid[dpos]
				Lmid[dpos] <- NA
				delta[dpos] <- NA
				if(all(is.na(delta))) break
			}
			delta.mid <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Lmid) - (1 - lwalp) > tol
			delta.gl <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Lguidel) - (1 - lwalp) > tol
			delta.gr <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Lguider) - (1 - lwalp) <= tol
			gvec <- delta.gl & delta.gr
			if(any(gvec, na.rm = TRUE)){
				tpos <- grep(TRUE, gvec & delta.mid)
				fpos <- grep(TRUE, gvec & !delta.mid)
				Lguidel[tpos] <- Lmid[tpos]
				Lguider[tpos] <- Lguider[tpos]
				Lguidel[fpos] <- Lguidel[fpos]
				Lguider[fpos] <- Lmid[fpos]
				Lmid <- (Lguidel + Lguider)/2
			}
			delta <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Lmid) - (1 - lwalp)
		}
	}

	# 上限の算出
	Ulim <- c()# 非心パラメータを保存するベクトル
	Ubase <- qf(p = 1 - upalp * 5e-04, df1 = ndf, df2 = ddf)
	delta <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Ubase) - upalp
	if(any(delta < 0)){# 解を出せない箇所がある場合
		Ubase[pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Ubase) < upalp] <- 1e-08
		if(any(pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Ubase) < upalp)){
			Ubase[pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Ubase) < upalp] <- NA
			Ulim[delta < 0] <- NA
		}
	}

	if(!all(is.na(Ubase))){# １つ以上の解が出せる場合
		Uvec <- c()
		U1 <- Ubase
		U2 <- Ubase
		repeat{
			U2 <- U1 * (1 + JmpProp)
			delta <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = U2) - upalp
			if(any(delta <= tol, na.rm = TRUE)){
				tpos <- grep(TRUE, delta <= tol)
				Uvec[tpos] <- U2[tpos]
				U2[tpos] <- NA
				delta[tpos] <- NA
				if(all(is.na(delta))) break
			}
			U1 <- U2
		}
		Uguidel <- Uvec / (1 + JmpProp)
		Uguider <- Uvec
		Umid <- (Uguidel + Uguider)/2

		delta <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Umid) - upalp
		repeat{
			if(any(abs(delta) <= tol, na.rm = TRUE)){
				dpos <- grep(TRUE, delta <= tol)
				Ulim[dpos] <- Umid[dpos]
				Umid[dpos] <- NA
				delta[dpos] <- NA
				if(all(is.na(delta))) break
			}
			delta.mid <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Umid) - upalp > tol
			delta.gl <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Uguidel) - upalp > tol
			delta.gr <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Uguider) - upalp <= tol
			gvec <- delta.gl & delta.gr
			if(any(gvec, na.rm = TRUE)){
				tpos <- grep(TRUE, gvec & delta.mid)
				fpos <- grep(TRUE, gvec & !delta.mid)
				Uguidel[tpos] <- Umid[tpos]
				Uguider[tpos] <- Uguider[tpos]
				Uguidel[fpos] <- Uguidel[fpos]
				Uguider[fpos] <- Umid[fpos]
				Umid <- (Uguidel + Uguider)/2
			}
			delta <- pf(q = Fratio, df1 = ndf, df2 = ddf, ncp = Umid) - upalp
		}
	}
	return(list("lower.limit" = Llim, "upper.limit" = Ulim))
}


# 分散分析表を作る関数
anova.modeler <- function(dat, design, factnames = NA, type2 = FALSE, dmat = NULL, flev = NULL, cellN = NULL, full.elem = NA, 
	epsi.effect = NA, lb = FALSE, gg = FALSE, hf = FALSE, cm = FALSE, auto = FALSE, autov = NULL, mau = FALSE, har = FALSE, 
	iga = FALSE, ciga = FALSE, eta = FALSE, peta = FALSE, geta = NA, eps = FALSE, peps = FALSE, geps = NA, omega = FALSE, 
	omegana = FALSE, pomega = FALSE, gomega = NA, gomegana = NA, prep = FALSE, nesci = FALSE, inter = NA, bet.mse = NULL, 
	gss.qT = NA, post.esdenomis = NA, post.df.adj = NA, post.mse.adj = NA, esboot = FALSE, es.conf.level = 0.95){
	maxfact <- nchar(design) - 1# 実験計画全体における要因数
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数
	if(is.null(flev)) flev <- sapply(2:nchar(design), function(x) length(unique(dat[, x])))# 各要因の水準数
	if(is.null(cellN)) cellN <- length(unique(dat$s))

	# factnamesが省略されているときは名前をつける（デバッグ用）
	if(anyNA(factnames)) factnames <- LETTERS[1:maxfact]

	# 要因計画の型に合わせてラベルを作る
	if(anyNA(full.elem)){
		factmat <- cbind(c("s", LETTERS[1:maxfact]), c("s", factnames))
		full.elem <- do.call(cbind, lapply(1:(maxfact+1), function(y) combn(1:(maxfact+1), y, function(x) c(paste0(factmat[x, 1], collapse = ":"), paste0(factmat[x, 2], collapse = " x ")))))
		full.elem <- cbind(full.elem, "Error", "Total")
	}
	if(anyNA(epsi.effect)) epsi.effect <- c("Global", unlist(lapply((betlen+1):maxfact, function(y) combn(factnames[(betlen+1):maxfact], y - betlen, function(x) paste0(x, collapse = " x ")))))

	# 要因計画のタイプ別の処理
	if(withlen == 0){# 被験者間計画の場合
		# epsilon.calcの出力に対応する情報
		epsi.info1 <- NA
		epsitab <- NULL
		ss.errs <- NA
		ano.info1 <- NULL
	}else{# 反復測定要因を含む場合
		# epsilon.calcの適用
		epsiresults <- epsilon.calc(dat = dat, design = design, flev = flev, cellN = cellN, mau = mau, har = har, 
			iga = iga, ciga = ciga, lb =lb, gg = gg, hf = hf, cm = cm, autov = autov, esboot = esboot)
		epsi.info1 <- epsiresults$epsi.info1
		epsitab <- epsiresults$epsitab
		ss.errs <- epsiresults$ss.errs
	}

	# ss.calcの適用
	sres <- ss.calc(dat = dat, design = design, dmat = dmat, ss.errs = ss.errs, type2 = type2, flev = flev, cellN = cellN)
	ss.results <- sres$ss.results
	ss.col <- ss.results[, 1]# 平方和を取り出す
	df.col <- ss.results[, 2]# 自由度を取り出す
	internal.lab <- row.names(ss.results)
	source.col <- full.elem[2, match(internal.lab, full.elem[1, ])]
	eflen <- length(ss.col)

	# 誤差項の特定と自由度の調整
	if(withlen == 0){# 被験者間計画の場合
		mse.row <- length(source.col) - 1
	}else{# 被験者内要因を含む計画の場合
		mse.row <- grep("s", internal.lab)

		# 各効果の自由度を調整するための係数をベクトル化する
		if(esboot){# ブートストラップ計算の場合
			mdf <- pmin(1, rep(c(1, epsiresults$sph.ep), c(mse.row[1], diff(mse.row))))
		}else if(iga){
			mdf <- 1
			ano.info1 <- "== Huynh's Improved General Approximation Test =="
		}else if(ciga){
			mdf <- 1
			ano.info1 <- "== Algina-Lecoutre's Corrected Improved General Approximation Test =="
		}else if(lb){
			mdf <- pmin(1, rep(c(1, epsitab$LB[epsitab$Effect != "Global"]), c(mse.row[1], diff(mse.row))))
			ano.info1 <- "== Geisser-Greenhouse's Conservative Test =="
		}else if(gg){
			mdf <- pmin(1, rep(c(1, epsitab$GG[epsitab$Effect != "Global"]), c(mse.row[1], diff(mse.row))))
			ano.info1 <- "== Adjusted by Greenhouse-Geisser's Epsilon =="
		}else if(hf){
			mdf <- pmin(1, rep(c(1, epsitab$HF[epsitab$Effect != "Global"]), c(mse.row[1], diff(mse.row))))
			ano.info1 <- "== Adjusted by Huynh-Feldt-Lecoutre's Epsilon =="
		}else if(cm){
			mdf <- pmin(1, rep(c(1, epsitab$CM[epsitab$Effect != "Global"]), c(mse.row[1], diff(mse.row))))
			ano.info1 <- "== Adjusted by Chi-Muller's Epsilon =="
		}else if(auto){
			sigepsi <- epsitab
			sigepsi$GG[((sigepsi$sig.mark == "") | (sigepsi$sig.mark == "ns"))] <- 1
			mdf <- pmin(1, rep(c(1, sigepsi$GG[sigepsi$Effect != "Global"]), c(mse.row[1], diff(mse.row))))
			ano.info1 <- "== Adjusted by Greenhouse-Geisser's Epsilon for Suggested Violation =="
		}else{
			mdf <- 1
			ano.info1 <- NULL
		}

		# 自由度を調整する
		df.col <- c(mdf, 1) * df.col
	}

	dbase <- rep(1, eflen)
	dbase[c(mse.row, length(dbase))] <- NA
	f.denomi <- rep(mse.row, c(mse.row[1], diff(mse.row)))
	f.denomi[mse.row] <- NA
	f.denomi <- c(f.denomi, NA)

	# 分散分析表を作る
	if(!is.null(bet.mse)){# MSeを引き継ぐ場合
		ss.col[mse.row] <- bet.mse[[2]]# ss.col
		df.col[mse.row] <- bet.mse[[3]]# df.col
		ss.qT <- gss.qT
	}else{
		ss.qT <- sum(ss.col[-eflen])
	}
	ms.col <- ss.col / df.col# MSを計算する
	f.col <- ms.col[1:length(ms.col)] / ms.col[f.denomi]# F値を計算する

	# IGA，CIGAの適用
	if((iga && !is.na(epsi.info1[1])) | (ciga && !is.na(epsi.info1[1]))){
		fillnames <- c("", paste0(source.col, " x ")[seq(from = 1, length.out = mse.row[1] - 1)])
		epsi.effect <- c("Global", unlist(lapply(epsi.effect[-1], function(x) paste0(fillnames, x))))
		wenum <- length(mse.row) - 1
		mfv <- c(rep(1, mse.row[1]), epsitab$multiplier[epsitab$Effect != "Global"], rep(NA, wenum))
		mfv <- c(mfv[order(c(1:(length(mfv) - wenum), mse.row[-1] - (1:wenum)))], 1)

		iga.df <- c(df.col[1:mse.row[1]], epsitab$adj.ndf[epsitab$Effect != "Global"], 
			epsitab$adj.ddf[epsitab$Effect != "Global"][seq(from = 1, by = mse.row[1], length.out = wenum)])
		iga.df <- iga.df[order(c(1:(length(iga.df) - wenum), mse.row[-1] - (1:wenum)))]
		iga.df <- append(iga.df, length(dat$y)-1)
		df.col <- ifelse(iga.df >= df.col, df.col, iga.df)# 推定した自由度がもとの自由度よりも高くなった場合は調整を行わない
	}else{
		mfv <- 1# 適用しないときは１（調整なし）
	}

	f.col <- f.col / mfv# IGA，CIGAのための推定値によってF値を調整
	p.col <- pf(f.col, df.col, df.col[f.denomi], lower.tail = FALSE)# p値を算出する

	# 効果量の計算と追加
	esmat <- NULL# 効果量保存用
	esdenomis <- NULL# 効果量計算の分母保存用
	es.df.adjs <- NULL
	es.mse.adjs <- NULL
	ncplw <- NULL
	ncpup <- NULL
	escilw <- NULL
	esciup <- NULL
	if(eta){# イータ二乗
		eta.col <- ss.col / ss.qT
		eta.col[is.na(f.denomi)] <- NA
		esmat <- cbind(esmat, "eta^2" = eta.col)
		esdenomis <- cbind(esdenomis, "eta" = ss.qT/dbase)
		if(nesci){# 非心F分布に基づく信頼区間
			if(!is.null(bet.mse)){
				df.adj <- post.df.adj[match("eta", dimnames(post.df.adj)[[2]])]
				mse.adj <- post.mse.adj[match("eta", dimnames(post.mse.adj)[[2]])]
			}else{
				df.adj <- df.col[length(df.col)] - df.col[!is.na(f.denomi)]
				mse.adj <- (ss.qT - ss.col[!is.na(f.denomi)]) / df.adj
			}
			f.adj <- ms.col[!is.na(f.denomi)] / mse.adj
			eta.lambda <- qlambda.ncf(f.adj, df.col[!is.na(f.denomi)], df.adj, conf.level = es.conf.level)
			lambda.lw <- pmax(0, eta.lambda$lower.limit, na.rm = TRUE)
			lambda.up <- pmax(0, eta.lambda$upper.limit, na.rm = TRUE)
			es.df.adjs <- cbind(es.df.adjs, "eta" = df.adj)
			es.mse.adjs <- cbind(es.mse.adjs, "eta" = mse.adj)
			ncplw <- c(ncplw, eta.lambda$lower.limit)
			ncpup <- c(ncpup, eta.lambda$upper.limit)
			escilw <- c(escilw, lambda.lw / (lambda.lw + df.col[!is.na(f.denomi)] + df.adj + 1))
			esciup <- c(esciup, lambda.up / (lambda.up + df.col[!is.na(f.denomi)] + df.adj + 1))
		}
	}
	if(peta){# 偏イータ二乗
		peta.col <- ss.col / (ss.col + ss.col[f.denomi])
		esmat <- cbind(esmat, "p.eta^2" = peta.col)
		esdenomis <- cbind(esdenomis, "peta" = ss.col + ss.col[f.denomi])
		if(nesci){# 非心F分布に基づく信頼区間
			peta.lambda <- qlambda.ncf(f.col[!is.na(f.denomi)], df.col[!is.na(f.denomi)], 
					df.col[na.omit(f.denomi)], conf.level = es.conf.level)
			lambda.lw <- pmax(0, peta.lambda$lower.limit, na.rm = TRUE)
			lambda.up <- pmax(0, peta.lambda$upper.limit, na.rm = TRUE)
			ncplw <- c(ncplw, peta.lambda$lower.limit)
			ncpup <- c(ncpup, peta.lambda$upper.limit)
			escilw <- c(escilw, lambda.lw / (lambda.lw + df.col[!is.na(f.denomi)] + df.col[na.omit(f.denomi)] + 1))
			esciup <- c(esciup, lambda.up / (lambda.up + df.col[!is.na(f.denomi)] + df.col[na.omit(f.denomi)] + 1))
		}
	}
	if(!anyNA(geta)){# 一般化イータ二乗
		if(!is.null(bet.mse)){# 分母を引き継いでいる場合（被験者間計画の下位検定のみ）
			meas.row <-0
			measvec <- 1
			geta.denomi <- ss.col + post.esdenomis[match("geta", dimnames(post.esdenomis)[[2]])]
			geta.denomi[is.na(f.denomi)] <- NA
		}else if(!is.logical(geta)){# 被験者間要因の中に測定変数（個人差変数）がある場合
			eff.internal <- gsub("Error", NA, gsub("Total", NA, internal.lab))
			source2int <- sapply(geta, function(x) LETTERS[match(x, factnames)])
			measfact <- unique(unlist(lapply(source2int, function(x) grep(x, eff.internal))))# 個人差変数を含む効果の取り出し
			meas.row <- setdiff(na.omit(measfact), mse.row)# 誤差平方和を除く
			measvec <- rep(1, eflen)
			measvec[measfact] <- 0# measfactに含まれる効果は分母に加える必要がないので０を代入
			geta.denomi <- measvec * ss.col + sum(ss.col[c(meas.row, mse.row)])
			geta.denomi[c(mse.row, length(geta.denomi))] <- NA
		}else{
			meas.row <- 0
			measvec <- 1
			geta.denomi <- ss.col + sum(ss.col[mse.row])
			geta.denomi[c(mse.row, length(geta.denomi))] <- NA
		}
		geta.col <- ss.col / geta.denomi
		esmat <- cbind(esmat, "G.eta^2" = geta.col)
		esdenomis <- cbind(esdenomis, "geta" = geta.denomi - ss.col)
		if(nesci){# 非心F分布に基づく信頼区間
			ss.meas <- sum(ss.col[c(meas.row, mse.row)])
			if(!is.null(bet.mse)){
				df.adj <- post.df.adj[match("geta", dimnames(post.df.adj)[[2]])]
				mse.adj <- post.mse.adj[match("geta", dimnames(post.mse.adj)[[2]])]
			}else{
				df.adj <- sum(df.col[c(meas.row, mse.row)]) + ((measvec - 1) * df.col)[!is.na(f.denomi)]
				mse.adj <- (ss.meas + ((measvec - 1) * ss.col)[!is.na(f.denomi)]) / df.adj
			}
			f.adj <- ms.col[!is.na(f.denomi)] / mse.adj
			geta.lambda <- qlambda.ncf(f.adj, df.col[!is.na(f.denomi)], df.adj, conf.level = es.conf.level)
			lambda.lw <- pmax(0, geta.lambda$lower.limit, na.rm = TRUE)
			lambda.up <- pmax(0, geta.lambda$upper.limit, na.rm = TRUE)
			es.df.adjs <- cbind(es.df.adjs, "geta" = df.adj)
			es.mse.adjs <- cbind(es.mse.adjs, "geta" = mse.adj)
			ncplw <- c(ncplw, geta.lambda$lower.limit)
			ncpup <- c(ncpup, geta.lambda$upper.limit)
			escilw <- c(escilw, lambda.lw / (lambda.lw + df.col[!is.na(f.denomi)] + df.adj + 1))
			esciup <- c(esciup, lambda.up / (lambda.up + df.col[!is.na(f.denomi)] + df.adj + 1))
		}
	}
	if(eps){# イプシロン二乗
		eps.col <- (ss.col - df.col * ms.col[f.denomi]) / ss.qT
		eps.col[is.na(f.denomi)] <- NA
		esmat <- cbind(esmat, "epsilon^2" = eps.col)
		esdenomis <- cbind(esdenomis, "eps" = ss.qT/dbase)
		if(nesci){# 非心F分布に基づく信頼区間
			if(!is.null(bet.mse)){
				df.adj <- post.df.adj[match("eps", dimnames(post.df.adj)[[2]])]
				mse.adj <- post.mse.adj[match("eps", dimnames(post.mse.adj)[[2]])]
			}else{
				df.adj <- df.col[length(df.col)] - df.col[!is.na(f.denomi)]
				mse.adj <- (ss.qT - ss.col[!is.na(f.denomi)]) / df.adj
			}
			f.adj <- ms.col[!is.na(f.denomi)] / mse.adj
			eps.lambda <- qlambda.ncf(f.adj, df.col[!is.na(f.denomi)], df.adj, conf.level = es.conf.level)
			lambda.lw <- pmax(0, eps.lambda$lower.limit, na.rm = TRUE)
			lambda.up <- pmax(0, eps.lambda$upper.limit, na.rm = TRUE)
			es.df.adjs <- cbind(es.df.adjs, "eps" = df.adj)
			es.mse.adjs <- cbind(es.mse.adjs, "eps" = mse.adj)
			ncplw <- c(ncplw, eps.lambda$lower.limit)
			ncpup <- c(ncpup, eps.lambda$upper.limit)
			ss.lw <- ss.qT * (lambda.lw / (lambda.lw + df.col[!is.na(f.denomi)] + df.adj + 1))
			ss.up <- ss.qT * (lambda.up / (lambda.up + df.col[!is.na(f.denomi)] + df.adj + 1))
			ms.lw <- (ss.qT - ss.lw) / df.adj
			ms.up <- (ss.qT - ss.up) / df.adj
			escilw <- c(escilw, (ss.lw - df.col[!is.na(f.denomi)] * ms.lw) / ss.qT)
			esciup <- c(esciup, (ss.up - df.col[!is.na(f.denomi)] * ms.up) / ss.qT)
		}
	}
	if(peps){# 偏イプシロン二乗
		peps.col <- (ss.col - df.col * ms.col[f.denomi]) / (ss.col + ss.col[f.denomi])
		esmat <- cbind(esmat, "p.epsilon^2" = peps.col)
		esdenomis <- cbind(esdenomis, "peps" = ss.col + ss.col[f.denomi])
		if(nesci){# 非心F分布に基づく信頼区間
			peps.lambda <- qlambda.ncf(f.col[!is.na(f.denomi)], df.col[!is.na(f.denomi)], df.col[na.omit(f.denomi)],
				 conf.level = es.conf.level)
			lambda.lw <- pmax(0, peps.lambda$lower.limit, na.rm = TRUE)
			lambda.up <- pmax(0, peps.lambda$upper.limit, na.rm = TRUE)
			ncplw <- c(ncplw, peps.lambda$lower.limit)
			ncpup <- c(ncpup, peps.lambda$upper.limit)
			ss.lw <- ss.qT * (lambda.lw / (lambda.lw + df.col[!is.na(f.denomi)] + df.col[na.omit(f.denomi)] + 1))
			ss.up <- ss.qT * (lambda.up / (lambda.up + df.col[!is.na(f.denomi)] + df.col[na.omit(f.denomi)] + 1))
			ms.lw <- (ss.qT - ss.lw) / df.col[na.omit(f.denomi)]
			ms.up <- (ss.qT - ss.up) / df.col[na.omit(f.denomi)]
			escilw <- c(escilw, (ss.lw - df.col[!is.na(f.denomi)] * ms.lw) / ss.qT)
			esciup <- c(esciup, (ss.up - df.col[!is.na(f.denomi)] * ms.up) / ss.qT)
		}
	}
	if(!anyNA(geps)){# 一般化イプシロン二乗
		if(!is.null(bet.mse)){# 分母を引き継いでいる場合（被験者間計画の下位検定のみ）
			meas.row <-0
			measvec <- 1
			geps.denomi <- ss.col + post.esdenomis[match("geps", dimnames(post.esdenomis)[[2]])]
			geps.denomi[is.na(f.denomi)] <- NA
		}else if(is.logical(geps) == FALSE){# 被験者間要因の中に測定変数（個人差変数）がある場合
			eff.internal <- gsub("Error", NA, gsub("Total", NA, internal.lab))
			source2int <- sapply(geps, function(x) LETTERS[match(x, factnames)])
			measfact <- unique(unlist(lapply(source2int, function(x) grep(x, eff.internal))))# 個人差変数を含む効果の取り出し
			meas.row <- setdiff(na.omit(measfact), mse.row)# 誤差平方和を除く
			measvec <- rep(1, eflen)
			measvec[measfact] <- 0
		}else{
			meas.row <- 0
			measvec <- 1
		}
		geps.denomi <- measvec * ss.col + sum(ss.col[c(meas.row, mse.row)])
		geps.col <- (ss.col - df.col * ms.col[f.denomi]) / geps.denomi
		esmat <- cbind(esmat, "G.epsilon^2" = geps.col)
		esdenomis <- cbind(esdenomis, "geps" = geps.denomi - ss.col)
		if(nesci){# 非心F分布に基づく信頼区間
			ss.meas <- sum(ss.col[c(meas.row, mse.row)])
			if(!is.null(bet.mse)){
				df.adj <- post.df.adj[match("geps", dimnames(post.df.adj)[[2]])]
				mse.adj <- post.mse.adj[match("geps", dimnames(post.mse.adj)[[2]])]
			}else{
				df.adj <- sum(df.col[c(meas.row, mse.row)]) + ((measvec - 1) * df.col)[!is.na(f.denomi)]
				mse.adj <- (ss.meas + ((measvec - 1) * ss.col)[!is.na(f.denomi)]) / df.adj
			}
			f.adj <- ms.col[!is.na(f.denomi)] / mse.adj
			geps.lambda <- qlambda.ncf(f.adj, df.col[!is.na(f.denomi)], df.adj, conf.level = es.conf.level)
			lambda.lw <- pmax(0, geps.lambda$lower.limit, na.rm = TRUE)
			lambda.up <- pmax(0, geps.lambda$upper.limit, na.rm = TRUE)
			es.df.adjs <- cbind(es.df.adjs, "geps" = df.adj)
			es.mse.adjs <- cbind(es.mse.adjs, "geps" = mse.adj)
			ncplw <- c(ncplw, geps.lambda$lower.limit)
			ncpup <- c(ncpup, geps.lambda$upper.limit)
			ss.lw <- ss.qT * (lambda.lw / (lambda.lw + df.col[!is.na(f.denomi)] + df.adj + 1))
			ss.up <- ss.qT * (lambda.up / (lambda.up + df.col[!is.na(f.denomi)] + df.adj + 1))
			ms.lw <- (ss.qT - ss.lw) / df.adj
			ms.up <- (ss.qT - ss.up) / df.adj
			escilw <- c(escilw, (ss.lw - df.col[!is.na(f.denomi)] * ms.lw) / ss.qT)
			esciup <- c(esciup, (ss.up - df.col[!is.na(f.denomi)] * ms.up) / ss.qT)
		}
	}
	if(omega){# オメガ二乗（加算モデル）；Dodd & Schultz（1973）の加算モデルの場合の計算式に基づく
		if(!is.null(bet.mse)){# 分母を引き継いでいる場合（被験者間計画の下位検定のみ）
			omega.denomi <- post.esdenomis[match("omega", dimnames(post.esdenomis)[[2]])]
		}else{
			omega.denomi <- sum((ss.col - df.col * ms.col[f.denomi])[!is.na(f.denomi)]) + nrow(dat) * (sum(ss.col[mse.row]) 
				/ sum(df.col[mse.row]))
		}
		omega.col <- (ss.col - df.col * ms.col[f.denomi]) / omega.denomi
		esmat <- cbind(esmat, "omega^2" = omega.col)
		esdenomis <- cbind(esdenomis, "omega" = omega.denomi/dbase)
		if(nesci){# 非心F分布に基づく信頼区間
			if(!is.null(bet.mse)){
				df.adj <- post.df.adj[match("omega", dimnames(post.df.adj)[[2]])]
				mse.adj <- post.mse.adj[match("omega", dimnames(post.mse.adj)[[2]])]
			}else{
				df.adj <- df.col[length(df.col)] - df.col[!is.na(f.denomi)]
				mse.adj <- (ss.qT - ss.col[!is.na(f.denomi)]) / df.adj
			}
			f.adj <- ms.col[!is.na(f.denomi)] / mse.adj
			omega.lambda <- qlambda.ncf(f.adj, df.col[!is.na(f.denomi)], df.adj, conf.level = es.conf.level)
			lambda.lw <- pmax(0, omega.lambda$lower.limit, na.rm = TRUE)
			lambda.up <- pmax(0, omega.lambda$upper.limit, na.rm = TRUE)
			ncplw <- c(ncplw, omega.lambda$lower.limit)
			ncpup <- c(ncpup, omega.lambda$upper.limit)
			es.df.adjs <- cbind(es.df.adjs, "omega" = df.adj)
			es.mse.adjs <- cbind(es.mse.adjs, "omega" = mse.adj)
			ss.lw <- ss.qT * (lambda.lw / (lambda.lw + df.col[!is.na(f.denomi)] + df.adj + 1))
			ss.up <- ss.qT * (lambda.up / (lambda.up + df.col[!is.na(f.denomi)] + df.adj + 1))
			ms.lw <- (ss.qT - ss.lw) / df.adj
			ms.up <- (ss.qT - ss.up) / df.adj
			escilw <- c(escilw, (ss.lw - df.col[!is.na(f.denomi)] * ms.lw) / (ss.qT + ms.lw))
			esciup <- c(esciup, (ss.up - df.col[!is.na(f.denomi)] * ms.up) / (ss.qT + ms.up))
		}
	}
	if(omegana){# オメガ二乗（非加算モデル）；Dodd & Schultz（1973）の非加算モデルの場合の計算式に基づく
		if(!is.null(bet.mse)){# 分母を引き継いでいる場合（被験者間計画の下位検定のみ）
			omegana.denomi <- post.esdenomis[match("omegana", dimnames(post.esdenomis)[[2]])]
		}else if(length(mse.row) == 1){# 被験者間計画の場合
			omegana.denomi <- sum((ss.col - df.col * ms.col[f.denomi])[!is.na(f.denomi)]) + sum(cellN * ms.col[mse.row])
		}else{# その他の計画の場合
			dflev <- flev[(betlen + 1):length(flev)]
			omega.dummy <- cellN * c(1, unlist(sapply(1:length(dflev), function(y) combn(1:length(dflev), y, function(x) 
				prod(dflev[x])))))
			omegana.denomi <- sum((ss.col - df.col * ms.col[f.denomi])[!is.na(f.denomi)]) + sum(omega.dummy * ms.col[mse.row])
		}
		omegana.col <- (ss.col - df.col * ms.col[f.denomi]) / omegana.denomi
		esmat <- cbind(esmat, "omega^2_NA" = omegana.col)
		esdenomis <- cbind(esdenomis, "omegana" = omegana.denomi/dbase)
		if(nesci){
			ncplw <- c(ncplw, rep(NA, sum(!is.na(f.col))))
			ncpup <- c(ncpup, rep(NA, sum(!is.na(f.col))))
			escilw <- c(escilw, rep(NA, sum(!is.na(gomegana.col))))
			esciup <- c(esciup, rep(NA, sum(!is.na(gomegana.col))))
		}
	}
	if(pomega){# 偏オメガ二乗
		pomega.col <- (ss.col - df.col * ms.col[f.denomi]) / (ss.col - df.col * ms.col[f.denomi] + nrow(dat) * ms.col[f.denomi])
		esmat <- cbind(esmat, "p.omega^2" = pomega.col)
		esdenomis <- cbind(esdenomis, "pomega" = ss.col - df.col * ms.col[f.denomi] + nrow(dat) * ms.col[f.denomi])
		if(nesci){# 非心F分布に基づく信頼区間
			pomega.lambda <- qlambda.ncf(f.col[!is.na(f.denomi)], df.col[!is.na(f.denomi)], df.col[na.omit(f.denomi)], conf.level = es.conf.level)
			lambda.lw <- pmax(0, pomega.lambda$lower.limit, na.rm = TRUE)
			lambda.up <- pmax(0, pomega.lambda$upper.limit, na.rm = TRUE)
			ncplw <- c(ncplw, pomega.lambda$lower.limit)
			ncpup <- c(ncpup, pomega.lambda$upper.limit)
			ss.lw <- ss.qT * (lambda.lw / (lambda.lw + df.col[!is.na(f.denomi)] + df.col[na.omit(f.denomi)] + 1))
			ss.up <- ss.qT * (lambda.up / (lambda.up + df.col[!is.na(f.denomi)] + df.col[na.omit(f.denomi)] + 1))
			ms.lw <- (ss.qT - ss.lw) / df.col[na.omit(f.denomi)]
			ms.up <- (ss.qT - ss.up) / df.col[na.omit(f.denomi)]
			escilw <- c(escilw, (ss.lw - df.col[!is.na(f.denomi)] * ms.lw) / (ss.qT + ms.lw))
			esciup <- c(esciup, (ss.up - df.col[!is.na(f.denomi)] * ms.up) / (ss.qT + ms.up))
		}
	}
	if(!anyNA(gomega)){# 一般化オメガ二乗（加算モデル）
		if(!is.null(bet.mse)){# 分母を引き継いでいる場合（被験者間計画の下位検定のみ）
			gomega.denomi <- (ss.col - df.col * ms.col[f.denomi]) + post.esdenomis[match("gomega", dimnames(post.esdenomis)[[2]])]
			gomega.denomi[is.na(f.denomi)] <- NA
		}else if(is.logical(gomega) == FALSE){# 被験者間要因の中に測定変数（個人差変数）がある場合
			eff.internal <- gsub("Error", NA, gsub("Total", NA, internal.lab))
			source2int <- sapply(gomega, function(x) LETTERS[match(x, factnames)])
			measfact <- unique(unlist(lapply(source2int, function(x) grep(x, eff.internal))))# 個人差変数を含む効果の取り出し
			meas.row <- setdiff(na.omit(measfact), mse.row)# 誤差平方和を除く
			measvec <- rep(1, eflen)
			measvec[measfact] <- 0
			gomega.denomi <- (measvec * (ss.col - df.col * ms.col[f.denomi]) + sum(ss.col[meas.row] - df.col[meas.row] * 
				ms.col[f.denomi][meas.row]) + nrow(dat) * (sum(ss.col[mse.row])/sum(df.col[mse.row])))
		}else{
			meas.row <- 0
			measvec <- 1
			gomega.denomi <- (measvec * (ss.col - df.col * ms.col[f.denomi]) + sum(ss.col[meas.row] - df.col[meas.row] * 
				ms.col[f.denomi][meas.row]) + nrow(dat) * (sum(ss.col[mse.row])/sum(df.col[mse.row])))
		}
		gomega.col <- (ss.col - df.col * ms.col[f.denomi]) / gomega.denomi
		esmat <- cbind(esmat, "G.omega^2" = gomega.col)
		esdenomis <- cbind(esdenomis, "gomega" = gomega.denomi - (ss.col - df.col * ms.col[f.denomi]))
		if(nesci){# 非心F分布に基づく信頼区間
			ss.meas <- sum(ss.col[c(meas.row, mse.row)])
			if(!is.null(bet.mse)){
				df.adj <- post.df.adj[match("gomega", dimnames(post.df.adj)[[2]])]
				mse.adj <- post.mse.adj[match("gomega", dimnames(post.mse.adj)[[2]])]
			}else{
				df.adj <- sum(df.col[c(meas.row, mse.row)]) + ((measvec - 1) * df.col)[!is.na(f.denomi)]
				mse.adj <- (ss.meas + ((measvec - 1) * ss.col)[!is.na(f.denomi)]) / df.adj
			}
			f.adj <- ms.col[!is.na(f.denomi)] / mse.adj
			gomega.lambda <- qlambda.ncf(f.adj, df.col[!is.na(f.denomi)], df.adj, conf.level = es.conf.level)
			lambda.lw <- pmax(0, gomega.lambda$lower.limit, na.rm = TRUE)
			lambda.up <- pmax(0, gomega.lambda$upper.limit, na.rm = TRUE)
			es.df.adjs <- cbind(es.df.adjs, "gomega" = df.adj)
			es.mse.adjs <- cbind(es.mse.adjs, "gomega" = mse.adj)
			ncplw <- c(ncplw, gomega.lambda$lower.limit)
			ncpup <- c(ncpup, gomega.lambda$upper.limit)
			ss.lw <- ss.qT * (lambda.lw / (lambda.lw + df.col[!is.na(f.denomi)] + df.adj + 1))
			ss.up <- ss.qT * (lambda.up / (lambda.up + df.col[!is.na(f.denomi)] + df.adj + 1))
			ms.lw <- (ss.qT - ss.lw) / df.adj
			ms.up <- (ss.qT - ss.up) / df.adj
			escilw <- c(escilw, (ss.lw - df.col[!is.na(f.denomi)] * ms.lw) / (ss.qT + ms.lw))
			esciup <- c(esciup, (ss.up - df.col[!is.na(f.denomi)] * ms.up) / (ss.qT + ms.up))
		}
	}
	if(!anyNA(gomegana)){# 一般化オメガ二乗（非加算モデル）
		if(length(mse.row) == 1){# 被験者間計画の場合
			omega.dummy <- cellN
		}else{# その他の計画の場合
			dflev <- flev[(betlen + 1):length(flev)]
			omega.dummy <- cellN * c(1, unlist(sapply(1:length(dflev), function(y) combn(1:length(dflev), y, function(x) prod(dflev[x])))))
		}
		if(is.logical(gomegana) == FALSE){# 被験者間要因の中に測定変数（個人差変数）がある場合
			eff.internal <- gsub("Error", NA, gsub("Total", NA, internal.lab))
			source2int <- sapply(gomegana, function(x) LETTERS[match(x, factnames)])
			measfact <- unique(unlist(lapply(source2int, function(x) grep(x, eff.internal))))# 個人差変数を含む効果の取り出し
			meas.row <- setdiff(na.omit(measfact), mse.row)# 誤差平方和を除く
			ss.meas <- sum(ss.col[setdiff(measfact, mse.row)] - df.col[setdiff(measfact, mse.row)] * ms.copy[setdiff(measfact, mse.row)])
			measvec <- rep(1, eflen)
			measvec[measfact] <- 0
		}else{
			meas.row <- 0
			measvec <- 1
		}
		ms.copy <- ms.col[f.denomi]
		gomegana.denomi <- measvec * (ss.col - df.col * ms.col[f.denomi]) + sum(ss.col[meas.row] - df.col[meas.row] * ms.copy[meas.row]) + sum(omega.dummy * ms.col[mse.row])
		if(!is.null(bet.mse)){# 分母を引き継いでいる場合（被験者間計画の下位検定のみ）
			gomegana.denomi <- (ss.col - df.col * ms.col[f.denomi]) + post.esdenomis[match("gomegana", dimnames(post.esdenomis)[[2]])]
			gomegana.denomi[is.na(f.denomi)] <- NA
		}
		gomegana.col <- (ss.col - df.col * ms.col[f.denomi]) / gomegana.denomi
		esmat <- cbind(esmat, "G.omega^2_NA" = gomegana.col)
		esdenomis <- cbind(esdenomis, "gomegana" = gomegana.denomi - (ss.col - df.col * ms.col[f.denomi]))
		if(nesci){
			ncplw <- c(ncplw, rep(NA, sum(!is.na(f.col))))
			ncpup <- c(ncpup, rep(NA, sum(!is.na(f.col))))
			escilw <- c(escilw, rep(NA, sum(!is.na(f.col))))
			esciup <- c(esciup, rep(NA, sum(!is.na(f.col))))
		}
	}
	if(prep){# p_rep（両側）
		prep.col <- pmin(0.9999, pnorm(qnorm(1 - p.col/2) / sqrt(2)))
		esmat <- cbind(esmat, "p_rep" = prep.col)
	}

	# 結果を返す
	if(esboot){# ブートストラップ計算の場合には効果量のみ返す
		if(is.na(inter)){# 主分析の場合
			eslist <- as.vector(esmat[-c(mse.row, length(df.col)), ])
			return(list("eslist" = eslist, "bet.mse" = c(NA, sum(ss.col[mse.row]), sum(df.col[mse.row])), 
				"ss.qT" = ss.qT, "esdenomis" = esdenomis))
		}else{# 単純主効果の検定の場合
			eslist <- as.vector(esmat[charmatch(inter, internal.lab), ])
			return(eslist)
		}
	}else{# 通常時の出力
		sig.col <- sig.sign(p.col)# p値が有意かどうかを判定して記号を表示する
		nesci.info1 <- NA
		nescitab <- NA
		if(is.null(esmat)){
			anovatab <- data.frame(source.col, ss.col, df.col, ms.col, f.col, p.col, sig.col, row.names = NULL)# 分散分析表をまとめたデータフレーム
		}else{
			anovatab <- data.frame(source.col, ss.col, df.col, ms.col, f.col, p.col, sig.col, esmat, row.names = NULL)# 効果量を加えたデータフレーム
			names(anovatab)[8:ncol(anovatab)] <- dimnames(esmat)[[2]]
			if(nesci){# 非心F分布に基づく効果量の信頼区間を算出した場合
				fcomlen <- sum(choose(maxfact, 1:maxfact))
				nesci.info1 <- c("=== Noncentral F Distribution-Based Confidence Intervals for Effect Sizes ===", paste0("=== ", 100 * es.conf.level, "% confidence intervals are calculated. ==="))
				nescitab <- data.frame("ES" = rep(dimnames(esmat)[[2]], each = sum(!is.na(f.col))), 
					"Source" = source.col[-c(mse.row, length(source.col))], "Estimate" = as.vector(esmat[!is.na(f.col), ]), 
					"CI_L" = escilw, "CI_U" = esciup, "ncp_L" = ncplw, "ncp_U" = ncpup, row.names = NULL)
				if(withlen > 0){# 反復測定要因を含む場合
					nesci.info1 <- c(nesci.info1, "*** CAUTION! Non-central parameters are not estimated for repeated-measures effects because their distributions are unknown. ***")
					if(betlen > 0){
						bcomlen <- sum(choose(betlen, 1:betlen)) * min(1, betlen)
						nescitab[-unlist(lapply(0:(nrow(nescitab)/fcomlen - 1), function(x) 1:bcomlen + x * fcomlen)), 4:7] <- NA
					}else{
						nescitab[, 4:7] <- NA
					}
				}
			}
		}
		if(is.na(inter)){# interに入力がない場合はanovatabとmse.rowを返す
			if(withlen > 0) epsitab$Effect <- epsi.effect[(2 * sum(withlen == 1)):length(epsi.effect)]# 一要因の場合のみ“Global”を省略
			return(list("epsi.info1" = epsi.info1, "epsitab" = epsitab, "ano.info1" = ano.info1, "anovatab" = anovatab, 
				"mse.row" = mse.row, "internal.lab" = internal.lab, "dmat" = sres$dmat, "flev" = flev, "cellN" = cellN, 
				"full.elem" = full.elem, "epsi.effect" = epsi.effect, "nesci.info1" = nesci.info1, "nescitab" = nescitab, 
				"esdenomis" = esdenomis, "es.df.adjs" = es.df.adjs, "es.mse.adjs" = es.mse.adjs))
		}else{# 単純主効果の場合はintertabを返す
			# 単純主効果の検定用の出力を用意する
			sim.row <- charmatch(inter, internal.lab)
			intertab <- rbind(anovatab[sim.row, ], anovatab[f.denomi[sim.row], ])
			if(nesci){
				sim.esrow <- charmatch(inter, internal.lab[-c(mse.row, length(source.col))])
				nescitab <- nescitab[sim.esrow + fcomlen * 0:(nrow(nescitab)/fcomlen - 1), ]
			}

			# 球面性検定の結果からinterに関する部分のみ取り出す
			if(charmatch(inter, strsplit(design, "")[[1]]) < charmatch("s", strsplit(design, "")[[1]])){
				# 被験者間要因ならNAの行を返す
				if(iga || ciga) interepsi <- rep(NA, 11)# IGA，CIGAを使ったときは列数が多い
				else interepsi <- rep(NA, 10)
			}else{
				interepsi <- epsitab[charmatch(inter, epsitab$Effect), ]
			}
			return(list("intertab" = intertab, "interepsi" = interepsi, "internal.lab" = internal.lab, 
				"dmat" = sres$dmat, "flev" = flev, "cellN" = cellN, "nescitab" = nescitab))
		}
	}
}


# ムーア・ペンローズの逆行列を計算する関数
mpginv <- function (xmat, tol = .Machine$double.eps^(2/3)){
	sx <- svd(xmat)
	pv <- (sx$d > max(tol * sx$d[1], 0))
	if(all(pv)){
		invmat <- sx$v %*% (1/sx$d * t(sx$u))
	}else if(any(pv)){
		invmat <- sx$v[, pv, drop = FALSE] %*% (1/sx$d[pv] * t(sx$u[, pv, drop = FALSE]))
    }else{
		invmat <- array(0, c(ncol(xmat), nrow(xmat)))
	}
	return(invmat)
}


# Welch-Jamesアプローチに基づく近似検定を行う関数
# pairwiseが指定されている場合は，指定された要因の含むすべての水準についてのペアワイズ比較を行う
# Lix, L. M., & Keselman, H. J. (1995). Approximate degrees of freedom tests: A unified perspective on testing for mean equality. Psychological Bulletin, 117, 547-560.
wj.calc <- function(dat, design, pairwise = NA){
	maxfact <- nchar(design) - 1# 実験計画全体における要因数
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数
	flev <- sapply(2:nchar(design), function(x) nlevels(dat[, x]))# 各要因の水準数
	ol <- prod(flev[min(1, betlen):betlen])# 全被験者間要因の組み合わせ水準数を取得
	rl <- ifelse(withlen == 0, 1, prod(flev[(betlen+1):maxfact]))# 全被験者内要因の組み合わせ水準数を取得

	# 反復測定要因に沿った分割パターンを作成
	if(withlen == 0){
		reppat <- rep(1, nrow(dat))# 反復測定要因なし＝分割しない場合
	}else{
		reppat <- interaction(dat[, maxfact:(betlen+1) + 1])# 反復測定要因の組み合わせ分だけ分割
	}

	# データフレームを分割し，共分散行列を作成
	if(betlen == 0){# 被験者間要因がないときはデータフレームを分割しない
		othN <- length(unique(dat$s))# サンプルサイズ
		mdmat <- do.call(cbind, tapply(dat$y, reppat, function(x) x - mean(x, na.rm = TRUE)))# 平均偏差
		smat <- crossprod(mdmat)/(othN - 1)/othN# 共分散行列をサンプルサイズで割ったもの
	}else{# 被験者間要因の組み合わせ水準ごとにデータフレームを分割
		othnum <- (betlen:1) + 1# 被験者間要因の列番号；後の方の要因のラベルを先に並べる
		othN <- as.vector(table(dat[names(dat)[othnum]]) / rl)# 被験者間要因の各組み合わせにおけるサンプルサイズをベクトル化
		rdat <- cbind(dat, "reppat" = reppat)# 分割パターンをデータに結合
		mdmat <- lapply(split(rdat, rdat[names(rdat)[othnum]]), function(x) do.call(cbind, tapply(x$y, x$reppat, function(w) w - mean(w, na.rm = TRUE))))# 平均偏差
		covmat <- lapply(1:ol, function(x) crossprod(mdmat[[x]])/(othN[x] - 1)/othN[x])# 共分散行列をサンプルサイズで割ったもの
		smat <- do.call(rbind, lapply(1:ol, function(x) t(diag(ol)[x, ]) %x% covmat[[x]]))# ブロック直交行列化
	}

	# 各効果に対応するデザイン行列を作成
	factcomb <- expand.gmatrix(replicate(maxfact, list(0:1)))[-1, , drop = FALSE]# 全組み合わせのパターン
	labbase <- apply(factcomb, 1, function(x) paste0(LETTERS[1:maxfact][x == 1], sep = ":", collapse = ""))
	comblabel <- sapply(labbase, function(x) substr(x, 1, nchar(x) - 1))# 効果名のラベル
	names(comblabel) <- NULL
	labord <- order(nchar(comblabel), comblabel)
	factcomb <- factcomb[labord, , drop = FALSE]# 行名に対応するよう組み合わせのパターンを並べ替え
	comblabel <- comblabel[labord]# 効果名のラベルを並べ替え
	row.names(factcomb) <- comblabel# 組み合わせのパターンに行名をつける
	rmat <- lapply(flev, function(x) cbind(1, -1 * diag(x - 1)))# 行列パターン；効果に組み入れる場合に使う
	rvec <- lapply(flev, function(x) array(1, c(1, x)))# ベクトルパターン；効果に組み入れない場合に使う

	# 使用する行列パターンを決定
	if(is.na(pairwise)){# すべての主効果と交互作用について検定
		adf.R <- lapply(1:nrow(factcomb), function(x) Reduce(f = kronecker, x = ifelse(factcomb[x, ] == 1, rmat, rvec)))
	}else{# 指定のあった要因内の全水準の組み合わせについてペアワイズ比較
		bonl <- nlevels(dat[, pairwise])
		bon.name <- combn(bonl, 2, function(x) paste0(levels(dat[, pairwise])[x][1], "-", levels(dat[, pairwise])[x][2]))
		contbase <- c(1, -1, rep(0, bonl - 2))
		contpairs <- combn(bonl, 2, function(x) array(contbase[order(c(x, setdiff(1:bonl, x)))], c(1, bonl)), simplify = FALSE)
		contfacts <- rep(1, maxfact)
		contfacts[match(pairwise, names(dat))-1] <- 0
		adf.R <- lapply(1:length(contpairs), function(x) Reduce(f = kronecker, x = ifelse(contfacts == 1, rvec, contpairs[x])))
	}

	# 群ごとの処理用の行列を作成
	qbase <- c(1, rep(0, ol - 1))
	adf.Q <- lapply(1:ol, function(x) diag(rep(qbase[order(c(x, setdiff(1:ol, x)))], each = rl)))

	# 各統計量の計算
	mu <- as.vector(tapply(dat$y, dat[, (maxfact+1):2], function(x) mean(x, na.rm = TRUE)))
	adf.T <- sapply(adf.R, function(x) t(x %*% mu) %*% (mpginv(x %*% smat %*% t(x))) %*% (x %*% mu))
	innmat <- lapply(adf.R, function(x) lapply(adf.Q, function(w) (smat %*% t(x)) %*% (mpginv(x %*% smat %*% t(x))) %*% (x %*% w)))
	adf.A <- sapply(innmat, function(x) sum(sapply(x, function(w) sum(diag(w %*% w)) + sum(diag(w))^2) / (othN - 1))/2)

	adf.df1 <- sapply(adf.R, function(x) nrow(x))
	adf.cvals <- adf.df1 + 2 * adf.A - (6 * adf.A) / (adf.df1 + 2)
	adf.df2 <- adf.df1 * (adf.df1 + 2) / (3 * adf.A)

	# 出力をデータフレームにまとめる
	if(is.na(pairwise)){
		pvals <- pf(adf.T/adf.cvals, adf.df1, adf.df2, lower.tail = FALSE)
		wjtab <- data.frame("Source" = comblabel, "approx.F" = adf.T/adf.cvals, "df1" = adf.df1, 
			"df2" = adf.df2, "p.value" = pvals, "sig.col" = sig.sign(pvals))
	}else{
		wjtab <- data.frame("pair" = bon.name, "t" = sqrt(adf.T/adf.cvals), "df" = adf.df2, 
			"p.value" = pt(sqrt(adf.T/adf.cvals), adf.df2, lower.tail = FALSE) * 2)
	}
	return(wjtab)
}


# 修正Bonferroniの方法（Holmの方法，Shafferの方法，Holland-Copenhaverの方法）による多重比較を行う関数
# デフォルトはShafferの方法を適用し，holm = TとするとHolmの方法，hc = TとするとHolland-Copenhaverの方法を適用する
# s2r = T，s2d = Tとすると，具体的な棄却のパターンを反映した有意水準の調整によるShafferの方法を適用する
mod.Bon <- function(dat, design, taref, bet.mse = NA, factlabel = NA, factnames = NA, type2 = FALSE, holm = FALSE, hc = FALSE, 
	s2r = FALSE, s2d = FALSE, fs1 = FALSE, fs2r = FALSE, fs2d = FALSE, welch = FALSE, alpha = 0.05, criteria = FALSE){
	# factnamesが省略されているときは名前をつける
	if(anyNA(factnames)) factnames <- LETTERS[1:(nchar(design)-1)]

	# 対象となる要因のラベルを得る
	if(is.na(factlabel)) factlabel <- taref

	bonl <- nlevels(dat[, taref])# 水準数の取得
	h0size <- bonl * (bonl-1)/2# 帰無仮説の個数
	comb.frame <- combn(bonl, 2)# 可能な対の組み合わせを作る
	tarlevs <- levels(dat[, taref])
	bon.name <- apply(comb.frame, 2, function(x) paste0(tarlevs[x][1], "-", tarlevs[x][2]))# 各比較のラベル
	bon.num <- match(taref, names(dat))-1# 分析対象となる要因が何番目の要因かを特定

	# 周辺平均を計算する
	cont.means <- tapply(dat$y, dat[, 2:nchar(design)], mean)# 各セルの平均を求める
	bon.means <- apply(cont.means, bon.num, mean)# 分析対象となる周辺平均を求める

	factlevels <- sapply(names(dat), function(x) nlevels(dat[, x]))# 各要因の水準数
	factlevels[match(taref, names(dat))] <- 2# 多重比較の対象となる効果の水準数を２に固定
	factlevels <- factlevels[!(factlevels == factlevels[1] | factlevels == factlevels[length(factlevels)])]# 最初と最後（sとyの列）を除く

	cont.N <- table(dat[, 2:nchar(design)])# 各セルのデータ数
	bon.denomi <- apply(1/cont.N, bon.num, mean) / (prod(factlevels)/2)# セルごとに重み付けしたデータ数の平均を残りの条件数で割ったもの
	bon.delta <- bon.means[comb.frame[1, ]] - bon.means[comb.frame[2, ]]# 平均偏差

	# 検定統計量と自由度を計算する
	if(welch){
		bontab <- wj.calc(dat, design, pairwise = taref)
		bon.p <- bontab$p.value
		bontab <- cbind(bontab[, 1, drop = FALSE], "difference" = bon.delta, bontab[, 2:4, drop = FALSE])
		rcomb.frame <- comb.frame[, order(bontab$p.value)]
		bontab <- bontab[order(bontab$p.value), ]# p値の小さい順に並べ替え
		bon.info2 <- "== Keselman-Keselman-Shaffer Statistics and Satterthwaite's Degrees of Freedom =="
	}else{
		# 分析対象が被験者間要因か被験者内要因かによって標準誤差を得る方法を変える
		if(length(bet.mse) != 1){
			# 被験者間要因の場合；上位の分析のMSeを適用する
			bon.df <- bet.mse$df.col# 自由度
			bon.Ve <- bet.mse$ms.col# 平均平方
			bon.info2 <- paste0("== The factor < ", factlabel, " > is analysed as independent means. ==")
		}else{
			# 被験者内要因の場合；比較する２水準ごとにMSeを再計算する
			bon.lev <- combn(levels(dat[, taref]), 2, function(x) x)# 各水準の組み合わせ
			subdat <- apply(bon.lev, 2, function(x) dat[dat[, taref] == x[1] | dat[, taref] == x[2], ])# データを多重比較の対象となる効果について２水準ずつのサブデータにリスト化
			for(i in 1:length(subdat)){
				subdat[[i]][, taref] <- subdat[[i]][, taref][, drop = TRUE]
			}
			bon.anova <- lapply(subdat, function(x) anova.modeler(dat = x, design = design, factnames = factnames, type2 = type2, 
				inter = taref)$intertab[2, ])
			bon.df <- sapply(bon.anova, function(x) x$df.col)# 自由度
			bon.Ve <- sapply(bon.anova, function(x) x$ms.col)
			bon.info2 <- paste0("== The factor < ", factlabel, " > is analysed as dependent means. ==")
		}

		# 検定統計量とｐ値を得る
		bon.SE <- sqrt((bon.denomi[comb.frame[1, ]] + bon.denomi[comb.frame[2, ]]) * bon.Ve)
		bon.t <- abs(bon.delta / bon.SE)# ｔ値は絶対値を取る
		bon.p <- pt(bon.t, bon.df, lower.tail = FALSE) * 2# 両側確率

		# 結果をデータフレームにまとめる
		bontab <- data.frame("pair" = bon.name, "difference" = bon.delta, "t" = bon.t, "df" = bon.df, "p.value" = bon.p)
		rcomb.frame <- comb.frame[, order(bontab$p.value)]
		bontab <- bontab[order(bontab$p.value), ]# p値の小さい順に並べ替え
	}

	# 調整した有意水準を設定する
	if(holm){
		p.criteria <- h0size:1# Holmの方法用の調整値
		bon.info1 <- paste0("== Holm's Sequentially Rejective Bonferroni Procedure ==")

	}else if(s2d || fs2d){# Donoguhe（2004）のアルゴリズムをベースとするShafferの多重比較のための論理ステップの計算
		# Donoghue, J. R. (2004). Implementing Shaffer's multiple comparison procedure for a large number of groups.
		# Recent developments in multiple comparison procedures (Institute of mathematical statistics-Lecture Notes-Monograph Series, 47), pp. 1-23.
		# Donoghueと完全に同じ手順ではないことに注意

		# 隣接行列を作る
		bon.comb <- comb.frame# 帰無仮説を表す行列
		bon.comb <- bon.comb[, order(bon.p)]# ｐ値の順に並べ替え
		hvec <- 1:bonl
		a.mat <- diag(rep(0, bonl))

		shaf.value <- c(h0size, rep(NA, h0size - 1))# ステップごとの仮説数を代入するためのベクトル
		allcomb <- unlist(lapply((bonl-1):1, function(y) combn(bonl, y, function(x) x, simplify = FALSE)), recursive = FALSE)# すべての帰無仮説の組み合わせを示すリスト

		for(j in 1:(h0size-1)){
			# 隣接行列に棄却された仮説を書き込む
			a.mat[bon.comb[1, j], bon.comb[2, j]] <- 1# 棄却された帰無仮説の部分に１を代入
			a.mat[bon.comb[2, j], bon.comb[1, j]] <- 1# 対角線を通して反対の側にも代入

			# 未分化クラスを作る
			# 隣接行列の下位行列の中から０のみで構成される正方行列を探す
			# 未分化クラスを表す行列：各行が各水準に相当；各列が帰無仮説を表す（互いに差がない水準に１を代入）
			undiff <- array(rep(0, bonl), c(bonl, 1))# ダミー
			cnt <- 1
			while(cnt <= length(allcomb)){
				hnum <- allcomb[[cnt]]
				if(max(colSums(undiff[hnum, , drop = FALSE])) == length(hnum)){
				# 上位の仮説に包含される仮説は含めない；カットはしない
					cnt <- cnt + 1
				}else if(sum(a.mat[hnum, hnum]) == 0){
				# 正方行列の場合は成立する帰無仮説を表す列を追加
					undiff <- cbind(undiff, 1 - 0^match(hvec, hnum, nomatch = 0))
					cnt <- cnt + 1
				}else{
				# その他の場合；このパターンは後に支持されることはないので，allcombからカット
					allcomb <- allcomb[-cnt]
				}
			}

			undiff <- undiff[, -1]# 一列目のダミーを除く
			gsize <- colSums(undiff)# 各グループの要素数を示すベクトル

			# sig.minを決定する
			sig.min <- max(gsize)^2# 最大クラスの要素数を二乗した値
			nxcand <- undiff# 未分化クラスのコピー
			gi <- 1
			while(ncol(nxcand) > 1 && nrow(nxcand) > 1){
				nxcand <- nxcand[(1:nrow(nxcand))[nxcand[, gi] == 0], , drop = FALSE]
				lengvec <- colSums(nxcand)# 各クラスの要素数
				sig.min <- sig.min + max(lengvec)^2# 最大クラスの要素数の二乗値を足す
				gi <- which.max(lengvec)# 最大クラスの番号
			}

			# don.maxを決定する
			don.smax <- sig.min

			for(i in 2:min(ncol(undiff)-1, bonl)){
				don.sig <- gsize[i]^2
				nxcand <- undiff
				gi <- i
				while(ncol(nxcand) > 1 && nrow(nxcand) > 1){
					nxcand <- nxcand[(1:nrow(nxcand))[nxcand[, gi] == 0], , drop = FALSE]
					lengvec <- colSums(nxcand)# 各クラスの要素数
					don.sig <- don.sig + max(lengvec)^2# 最大クラスの要素数の二乗値を足す
					gi <- which.max(lengvec)# 最大クラスの番号
				}
				don.smax <- max(don.sig, don.smax)# より大きい値を残す
			}
			shaf.value[j+1] <- (don.smax - bonl) / 2
		}

		if(s2d){
			p.criteria <- shaf.value# Shafferの方法用の調整値
			bon.info1 <- paste0("== Shaffer's Modified Sequentially Rejective Bonferroni Procedure [SPECIFIC] ==", "\n", 
				"== This computation is based on the algorithm by Donoghue (2004). ==")
			shaf.meth <- paste0(" [SPECIFIC] ==", "\n", "== This computation is based on the algorithm by Donoghue (2004). ==")
		}else{
			p.criteria <- c(shaf.value[2], shaf.value[2:length(shaf.value)])# F-Shafferの方法用の調整値
			bon.info1 <- paste0("== Shaffer's F-Modified Sequentially Rejective Bonferroni Procedure [SPECIFIC] ==", "\n", 
				"== This computation is based on the algorithm by Donoghue (2004). ==")
			shaf.meth <- paste0(" [SPECIFIC] ==", "\n", "== This computation is based on the algorithm by Donoghue (2004). ==")
		}

	}else{# Rasmussen（1993）のアルゴリズムによるShafferの多重比較のための論理ステップの計算
		# Rasmussen, J. L. (1993). Algorithm for Shaffer's multiple comparison tests. Educational and Psychological Measurement, 53, 329-335.

		# 平均間の異同パターンを表す行列を作る
		hpattern <- 2^(bonl-1)# 可能な真偽の仮説のパターン数
		nbuffer <- 2^((bonl-2):0)
		c.mat <- cbind(rep(0, hpattern), sapply(nbuffer, function(x) rep(rep(0:1, each = x), nbuffer[1]/x)))
		c.mat <- sapply(1:ncol(c.mat), function(x) rowSums(c.mat[, 1:x, drop = FALSE]))

		f.mat <- 1 * combn(bonl, 2, function(x) c.mat[, x[1]] != c.mat[, x[2]])# 各水準の組み合わせを表現する行列；帰無仮説が真のときに０，偽のときに１
		rebon.p <- bon.p[order(combn(rank(bon.means), 2, function(x) prod(x)))]# ｐ値の順序を平均値の大きさにそって並べ替え
		f.mat <- f.mat[, order(rebon.p)]# ｐ値の小さい順に列を並べ替え
		i.vector <- rowSums(f.mat)# 棄却される帰無仮説の数
		t.vector <- h0size - i.vector# 成立しうる真の帰無仮説の数

		if(s2r || fs2r){# 各比較までの特定の仮説が偽であったときの可能な真の帰無仮説の最大数
			shaf.value <- c(max(t.vector), max(t.vector[i.vector >= (2 - 1)][(f.mat[i.vector >= (2 - 1), 1:(2-1)]) == (2 - 1)]))
			shaf.value <- c(shaf.value, sapply(3:h0size, function(x) max(t.vector[i.vector >= (x - 1)][rowSums(f.mat[i.vector >= (x - 1), 1:(x-1)]) == (x - 1)])))
			shaf.meth <- paste0(" [SPECIFIC] ==", "\n", "== This computation is based on the algorithm by Rasmussen (1993). ==")
		}else{# 各比較までの任意の仮説が偽であったときの可能な真の帰無仮説の最大数
			shaf.value <- sapply(1:h0size, function(x) max(t.vector[i.vector >= (x - 1)]))
			shaf.meth <- " =="
		}

		if(fs1 || fs2r){
			p.criteria <- c(shaf.value[2], shaf.value[2:length(shaf.value)])# F-Shafferの方法用の調整値
			bon.info1 <- paste0("== Shaffer's F-Modified Sequentially Rejective Bonferroni Procedure", shaf.meth)
		}else{
			p.criteria <- shaf.value# Shafferの方法用の調整値
			bon.info1 <- paste0("== Shaffer's Modified Sequentially Rejective Bonferroni Procedure", shaf.meth)
		}
	}

	# 平均値の差の方向を調べ，不等号のベクトルを作る
	diff.direct <- ifelse(bontab$difference <= 0, " < ", " > ")
	bon.differ <- paste0(tarlevs[rcomb.frame[1, ]], diff.direct, tarlevs[rcomb.frame[2, ]])
	# 差が見られなかった場合の等号のベクトルを作る
	bon.equal <- paste0(tarlevs[rcomb.frame[1, ]], " = ", tarlevs[rcomb.frame[2, ]])

	if(criteria){# データフレームに調整済み有意水準の列を加える
		if(hc){
			bontab <- transform(bontab, "criteria" = 1 - (1 - alpha) ^ (1/p.criteria))# Sidakの不等式による有意水準の調整
			if(holm == TRUE) bon.info1 <- paste0("== Holm's Sequentially Rejective Sidak Procedure ==")
			else bon.info1 <- paste0("== Holland-Copenhaver's Improved Sequentially Rejective Sidak Procedure", shaf.meth)

			if(length(bet.mse) == 1) bon.info1 <- append(bon.info1, "*** CAUTION! This procedure might be inappropriate for dependent means. ***")
		}else{
			bontab <- transform(bontab, "criteria" = alpha/p.criteria)# Bonferroniの不等式による有意水準の調整
		}
		# 有意であった行は不等号，そうでない行は等号を表示する
		bon.sign <- ifelse(cummin(bontab$p.value < bontab$criteria), paste(bon.differ, "*", sep = " "), paste(bon.equal, " ", sep = " "))
	}else{# データフレームに調整済みｐ値の列を加える
		if(hc){
			bontab <- transform(bontab, "adj.p" = pmin(1, cummax((1-(1-bontab$p.value)^p.criteria))))# Sidakの不等式による調整済みｐ値
			if(holm == TRUE) bon.info1 <- paste0("== Holm's Sequentially Rejective Sidak Procedure ==")
			else bon.info1 <- paste0("== Holland-Copenhaver's Improved Sequentially Rejective Sidak Procedure", shaf.meth)

			if(length(bet.mse) == 1) bon.info1 <- append(bon.info1, "*** CAUTION! This procedure might be inappropriate for dependent means. ***")
		}else{
			bontab <- transform(bontab, "adj.p" = pmin(1, cummax(bontab$p.value * p.criteria)))# Bonferroniの不等式による調整済みｐ値
		}
		# 有意であった行は不等号，そうでない行は等号を表示する
		bon.sign <- ifelse(bontab$adj.p < alpha, paste(bon.differ, "*", sep = " "), paste(bon.equal, " ", sep = " "))
	}

	# 判定結果をデータフレームに反映する
	bontab <- transform(bontab, "significance" = bon.sign)

	# 記述統計量の計算
	b.sncol <- tapply(dat$y, dat[, taref], length)# セルごとのデータ数を計算
	b.sdcol <- tapply(dat$y, dat[, taref], sd)# セルごとの標準偏差を計算
	bonstat <- data.frame("Dummy" = levels(dat[, taref]), "n" = b.sncol, "Mean" = bon.means, "S.D." = b.sdcol)
	names(bonstat)[1] <- factlabel# 水準を表すラベルをfactlabelとして入力した値に置き換える
	bon.info3 <- paste0("== Alpha level is ", alpha, ". ==")

	bonresults <- list(factlabel, bon.info1, bon.info2, bon.info3, bonstat, bontab)
	names(bonresults) <- c(taref, "bon.info1", "bon.info2", "bon.info3", "bonstat", "bontab")
	return(bonresults)
}


# 下位検定を行う関数
post.analyses <- function(dat, design, factnames = NA, mainresults, type2 = FALSE, nopost = FALSE, holm = FALSE, hc = FALSE, 
	s2r = FALSE, s2d = FALSE, fs1 = FALSE, fs2r = FALSE, fs2d = FALSE, welch = FALSE, criteria = FALSE, 
	lb = FALSE, gg = FALSE, hf = FALSE, cm = FALSE, auto = FALSE, mau = FALSE, har = FALSE, iga = FALSE, ciga = FALSE, 
	eta = FALSE, peta = FALSE, geta = NA, eps = FALSE, peps = FALSE, geps = NA, omega = FALSE, omegana = FALSE, pomega = FALSE, 
	gomega = NA, gomegana = NA, prep = FALSE, nesci = FALSE){
	anovatab <- mainresults$anovatab
	internal.lab <- mainresults$internal.lab

	# 要因計画の型から被験者間要因と被験者内要因の情報を得る
	bet.with <- strsplit(design, "s")[[1]]

	# 効果が有意であった行のソースラベルを得る
	# sig.source <- internal.lab[!((anovatab$sig.col == "") | (anovatab$sig.col == "ns"))]
	sig.source <- internal.lab[-c(grep("s", internal.lab), grep("Total", internal.lab))]
	if(length(sig.source) == 0 | nopost){
		return(NA)# 有意な行が存在しないか，nopostオプションが指定されている場合はここで終了
	}else{
		# pro.fraction関数を反復適用
		postresults <- lapply(sig.source, function(x) pro.fraction(dat = dat, design = design, factnames = factnames, 
			postplan = x, bet.with = bet.with, mainresults = mainresults, type2 = type2, holm = holm, hc = hc, s2r = s2r, 
			s2d = s2d, fs1 = fs1, fs2r = fs2r, fs2d = fs2d, welch = welch, criteria = criteria, lb = lb, gg = gg, hf = hf, 
			cm = cm, auto = auto, mau = mau, har = har, iga = iga, ciga = ciga, eta = eta, peta = peta, geta = geta, eps = eps, 
			peps = peps, geps = geps, omega = omega, omegana = omegana, pomega = pomega, gomega = gomega, gomegana = gomegana, 
			prep = prep, nesci = nesci))
		names(postresults) <- sig.source

		return(postresults)
	}
}


# 効果のタイプに適した下位検定を割り当てる関数
pro.fraction <- function(dat, design, factnames = NA, postplan, bet.with, mainresults, type2 = FALSE, holm = FALSE, hc = FALSE, 
	s2r = FALSE, s2d = FALSE, fs1 = FALSE, fs2r = FALSE, fs2d = FALSE, welch = FALSE, criteria = FALSE, 
	lb = FALSE, gg = FALSE, hf = FALSE, cm = FALSE, auto = FALSE, mau = FALSE, har = FALSE, iga = FALSE, ciga = FALSE, 
	eta = FALSE, peta = FALSE, geta = NA, eps = FALSE, peps = FALSE, geps = NA, omega = FALSE, omegana = FALSE, pomega = FALSE, 
	gomega = NA, gomegana = NA, prep = FALSE, nesci = FALSE, esboot = FALSE){
	# 情報の展開
	anovatab <- mainresults$anovatab
	mse.row <- mainresults$mse.row
	internal.lab <- mainresults$internal.lab
	flev <- mainresults$flev# 各要因の水準数

	# 内部ラベルを文字列に変換し，その文字数を得る
	sig.term <- as.character(postplan)
	sig.num <- nchar(sig.term)
	sig.source <- as.character(anovatab$source.col[match(sig.term, internal.lab)])

	# 効果の種類によって違った処理を割り当てる
	if(sig.num > 3){# 高次の交互作用：効果のラベルを返す
		highx <- sig.source
		names(highx) <- sig.term
		return(highx)
	}else if(sig.num == 3){# １次の交互作用については，単純主効果の検討を行う
		maxfact <- nchar(design) - 1# 実験計画全体における要因数
		spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
		betlen <- spos - 1# 被験者間要因の数
		withlen <- maxfact - spos + 1# 被験者内要因の数

		# 分析する要因の特定
		each.term <- strsplit(sig.term, ":")[[1]]
		targetnm <- sapply(each.term, function(x) grep(x, LETTERS[1:maxfact]))# 分割する要因が主分析で何番目の要因に当たるかを表すベクトル
		rtargetnm <- sort(targetnm, decreasing = TRUE)# 逆順にしたもの
		desnm <- c(betlen, withlen)# オリジナルのデザインの被験者間・被験者内の要因数
		sublevn <- lapply(LETTERS[rtargetnm], function(x) desnm - diag(2)[grep(x, bet.with), ])# 単純主効果の検定での被験者間・被験者内の要因数
		subdesign <- sapply(sublevn, function(x) paste0(paste0(LETTERS[min(1, x[1]):x[1]], collapse = ""), "s", 
			paste0(LETTERS[(x[2] != 0) * (x[1]+1):sum(x)], collapse = "")))# 単純主効果の検定のデザイン
		subdesign <- rep(subdesign, flev[rtargetnm])# ターゲット要因の水準数だけ繰り返す

		# データフレームの分割
		all.lev <- unlist(lapply(rtargetnm + 1, function(x) levels(dat[, x])))# ターゲット要因の実際の水準名をベクトルの形に並べる
		nmline <- rep(rtargetnm, flev[rtargetnm])# ターゲット要因の位置情報を水準数だけ繰り返す（逆順）
		tfline <- rep(targetnm, flev[rtargetnm])# 要因の順に位置情報を繰り返したベクトル
		subline <- unlist(lapply(rtargetnm + 1, function(x) split(x = seq_len(nrow(dat)), dat[, x])), recursive = FALSE)
		subdat <- mapply(function(x, y) dat[x, -y], subline, nmline + 1, SIMPLIFY = FALSE)
		interlab <- rep(LETTERS[targetnm - 0:1], flev[rtargetnm])
		simtimes <- length(nmline)# 単純主効果の検定の実行回数

		# 分割したデータフレームのヘッダを付け直す
		for(i in 1:simtimes){
			names(subdat[[i]]) <- c("s", LETTERS[1:(maxfact-1)], "y")
		}

		if(withlen == 0){# 被験者間計画の場合，主分析から情報を引き継ぐ
			bet.mse <- anovatab[mse.row, ]
			gss.qT <- sum(anovatab$ss.col[-nrow(anovatab)])
			anlefpos <- match(LETTERS[tfline], internal.lab)
			if(!is.null(mainresults$esdenomis)){# 効果量算出の際の分母
				post.esdenomis <- mainresults$esdenomis[anlefpos, , drop = FALSE]
			}
			if(!is.null(mainresults$es.df.adjs)){# 効果量の信頼区間算出に関わる統計量
				post.guide <- match(LETTERS[tfline], dimnames(mainresults$es.df.adj)[[1]])
				post.df.adj <- mainresults$es.df.adjs[post.guide, , drop = FALSE]
				post.mse.adj <- mainresults$es.mse.adjs[post.guide, , drop = FALSE]
			}

			# 検定の実行
			sim.effects <- lapply(1:simtimes, function(x) anova.modeler(dat = subdat[[x]], design = subdesign[x], 
				factnames = factnames[-nmline[x]], type2 = type2, eta = eta, peta = peta, geta = geta, eps = eps, 
				peps = peps, geps = geps, omega = omega, omegana = omegana, pomega = pomega, gomega = gomega, gomegana = gomegana, 
				prep = prep, nesci = nesci, inter = interlab[x], bet.mse = bet.mse, gss.qT = gss.qT, 
				post.esdenomis = post.esdenomis[x, , drop = FALSE], post.df.adj = post.df.adj[x, , drop = FALSE], 
				post.mse.adj = post.mse.adj[x, , drop = FALSE]))
			simtab <- do.call(rbind, lapply(sim.effects, function(x) x$intertab))
			simepsi <- do.call(rbind, lapply(sim.effects, function(x) x$interepsi))
			simnesci <- do.call(rbind, lapply(sim.effects, function(x) x$nescitab))
			sim.internal.lab <- paste(rep(LETTERS[targetnm], flev[rtargetnm]), all.lev, sep = " at ")
			subbase <- paste(rep(factnames[targetnm], flev[rtargetnm]), all.lev, sep = " at ")

			# 出力の整理
			simeflen <- nrow(simtab)/2
			simefpos <- 1:simeflen# 単純主効果の行番号
			sim.internal.lab <- c(sim.internal.lab, "Error")# 内部処理用の列ラベル
			subsource <- c(subbase, "Error")# ソース列のラベル
			simepsi <- NA# 球面性検定の結果はなし
			simtab <- simtab[c(2 * 1:simeflen - 1, nrow(simtab)), ]

			# 単純主効果の多重比較のためにMSeを保存
			sim.bet.mse <- replicate(simeflen, bet.mse, simplify = FALSE)
		}else{# 反復測定要因を含む場合
			# 検定の実行
			sim.effects <- lapply(1:simtimes, function(x) anova.modeler(dat = subdat[[x]], design = subdesign[x], 
				factnames = factnames[-nmline[x]], type2 = type2, lb = lb, gg = gg, hf = hf, cm = cm, auto = auto, 
				mau = mau, har = har, iga = iga, ciga = ciga, eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, 
				geps = geps, omega = omega, omegana = omegana, pomega = pomega, gomega = gomega, gomegana = gomegana, 
				prep = prep, nesci = nesci, inter = interlab[x]))
			simtab <- do.call(rbind, lapply(sim.effects, function(x) x$intertab))
			simepsi <- do.call(rbind, lapply(sim.effects, function(x) x$interepsi))
			simnesci <- do.call(rbind, lapply(sim.effects, function(x) x$nescitab))
			sim.internal.lab <- paste(rep(LETTERS[targetnm], flev[rtargetnm]), all.lev, sep = " at ")
			subbase <- paste(rep(factnames[targetnm], flev[rtargetnm]), all.lev, sep = " at ")

			# 出力の整理
			simeflen <- nrow(simtab)/2
			simefpos <- 2 * 1:simeflen - 1# 単純主効果の行番号
			simer <- ifelse(targetnm <= betlen, "Er", paste0("s:", LETTERS[targetnm]))
			suber <- ifelse(targetnm <= betlen, "Er", paste0("s x ", factnames[targetnm]))
			sim.internal.lab <- c(sim.internal.lab, paste0(rep(simer, flev[rtargetnm]), " at ", all.lev))
			sim.internal.lab <- sim.internal.lab[order(c(simefpos, 2 * 1:simeflen))]# 内部処理用の列ラベル
			subsource <- c(subbase, paste0(rep(suber, flev[rtargetnm]), " at ", all.lev))
			subsource <- subsource[order(c(simefpos, 2 * 1:simeflen))]# ソース列のラベル
			if(!all(is.na(simepsi))){# 球面性検定の結果がある場合
				simepsi$Effect <- subsource[simefpos]# subsourceの奇数番の値をsimepsiの効果ラベルに貼り付ける
				simepsi <- simepsi[!is.na(simepsi$df), ]# dfがNAの行（被験者間効果の行）を除く
			}

			# 単純主効果の多重比較のために被験者間要因のMSeを保存；被験者内要因についてはNAを代入
			sim.bet.mse <- lapply(1:simtimes, function(x){if(tfline[x] <= betlen) simtab[x * 2, ] else NA})
		}

		# ソース列，行番号のラベルを張り替える
		simtab$source.col <- subsource
		row.names(simtab) <- NULL

		# 非心分布に基づく効果量の信頼区間を出力する場合
		if(nesci){
			estimes <- nrow(simnesci)/simtimes
			simnesci <- simnesci[order(rep(1:estimes, simtimes)), ]
			simnesci$Source <- rep(subbase, estimes)
		}

		# 記述統計量の計算
		sim.sncol <- as.vector(tapply(dat$y, dat[, rtargetnm + 1], length))# セルごとのデータ数を計算
		sim.mncol <- as.vector(tapply(dat$y, dat[, rtargetnm + 1], mean))# セルごとの平均を計算
		sim.sdcol <- as.vector(tapply(dat$y, dat[, rtargetnm + 1], sd))# セルごとの標準偏差を計算
		sim.stat <- data.frame("Term1" = rep(levels(dat[, targetnm[1] + 1]), each = flev[rtargetnm[1]]), 
			"Term2" = rep(levels(dat[, targetnm[2] + 1]), flev[rtargetnm[2]]), "n" = sim.sncol, 
			"Mean" = sim.mncol, "S.D." = sim.sdcol)

		# 行ラベルの張り替え
		names(sim.stat)[1:2] <- factnames[targetnm]

		# 有意であった行のソースをチェック
		sim.sig.col <- ((simtab$sig.col != "") & (simtab$sig.col != "ns"))[simefpos] & flev[tfline] >= 3# ３水準以上の場合のみ残す
		sim.sig.lab <- simtab$source.col[simefpos]

		# 多重比較を実行
		if(sum(sim.sig.col) == 0){
			sim.multresults <- NA# 有意な行がない場合はNAを代入
		}else{
			sim.multresults <- lapply((1:length(sim.sig.col))[sim.sig.col], function(x) mod.Bon(dat = subdat[[x]], 
				design = subdesign[x], taref = interlab[x], bet.mse = sim.bet.mse[[x]], factlabel = sim.sig.lab[x], 
				factnames = factnames[-nmline[x]], type2 = type2, holm = holm, hc = hc, s2r = s2r, s2d = s2d, 
				fs1 = fs1, fs2r = fs2r, fs2d = fs2d, welch = welch, criteria = criteria))
		}

		sim.dmat <- lapply(sim.effects, function(x) x$dmat)
		sim.cellN <- sapply(sim.effects, function(x) x$cellN)
		sim.flev <- lapply(sim.effects, function(x) x$flev)
		simresults <- list(sig.source, sim.stat, simepsi, simtab, simnesci, sim.multresults, sim.dmat, sim.cellN, sim.flev)
		names(simresults) <- c(sig.term, "sim.stat", "simepsi", "simtab", "simnesci", "sim.multresults", "sim.dmat", "sim.cellN", "sim.flev")
		return(simresults)
	}else if(sig.num == 1){# 主効果が有意で，水準数が３以上であれば多重比較を行う
		# 分析対象となるの項の列番号，水準数を取得
		col.num <- charmatch(sig.term, names(dat))# 列番号
		level.num <- nlevels(dat[, col.num])# 水準数

		# 水準数が３以上の場合にのみ，mod.Bon関数を適用する
		if(level.num >= 3){
			multfact <- grep(sig.term, bet.with[1])# 被験者間要因なら１，被験者内要因なら０を返す

			# 被験者間要因か被験者内要因かを判定して，mod.Bon関数にデータを送る
			if(!is.na(multfact[1])){
				if(substr(design, nchar(design), nchar(design)) == "s"){
				# 被験者間計画なら全体の誤差項のMSを得る
					bet.mse <- anovatab[charmatch("Error", internal.lab), ]
				}else{
				# 混合要因計画ならその効果の誤差項のMSを得る
					f.denomi <- rep(mse.row, c(mse.row[1], diff(mse.row)))
					bet.mse <- anovatab[f.denomi[charmatch(sig.term, internal.lab)], ]
				}
			}else{
				bet.mse <- NA
			}
			bonout <- mod.Bon(dat = dat, design = design, taref = sig.term, bet.mse = bet.mse, factlabel = sig.source, 
				factnames = factnames, type2 = type2, holm = holm, hc = hc, s2r = s2r, s2d = s2d, fs1 = fs1, fs2r = fs2r, 
				fs2d = fs2d, welch = welch, criteria = criteria)
			return(bonout)
		}else{
			return(NA)# 水準数が２ならNAを返す
		}
	}
}


# ブートストラップ法に基づいて効果量の信頼区間を計算する関数
# BCa法に基づく
boot.esci <- function(dat, design, factnames = NA, type2 = FALSE, nopost = FALSE, mainresults = NULL, postresults = NULL, 
	lb = FALSE, gg = FALSE, hf = FALSE, cm = FALSE, auto = FALSE, mau = FALSE, har = FALSE, iga = FALSE, ciga = FALSE, 
	eta = FALSE, peta = FALSE, geta = NA, eps = FALSE, peps = FALSE, geps = NA, omega = FALSE, omegana = FALSE, pomega = FALSE, 
	gomega = NA, gomegana = NA, prep = FALSE, interim = FALSE, B = 2000, conf.level = 0.95){
	# 効果量が指定されていない場合
	if(sum(c(eta, peta, geta, eps, peps, geps, omega, omegana, pomega, gomega, gomegana), na.rm = TRUE) == 0){
		warning("Please specify some effect sizes to be bootstrapped for their confidence intervals...")
		return(NA)
	}

	maxfact <- nchar(design) - 1# 実験計画全体における要因数
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数
	uniq.s <- unique(dat$s)

	# factnamesが省略されているときは名前をつける（デバッグ用）
	if(anyNA(factnames)) factnames <- LETTERS[1:maxfact]

	# 標本による結果の取得
	if(is.null(mainresults)){
		mainresults <- anova.modeler(dat = dat, design = design, factnames = factnames, type2 = type2, 
			lb = lb, gg = gg, hf = hf, cm = cm, auto = auto, mau = mau, har = har, iga = iga, ciga = ciga, 
			eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, 
			pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep)
	}
	if(is.null(postresults)){
		postresults <- post.analyses(dat = dat, design = design, factnames = factnames, mainresults = mainresults, type2 = type2, 
			nopost = nopost, lb = lb, gg = gg, hf = hf, cm = cm, auto = auto, mau = mau, har = har, iga = iga, ciga = ciga, 
			eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, 
			pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep)
	}
	eslen <- ncol(mainresults$anovatab) - 7# 指定された効果量の数
	estype <- names(mainresults$anovatab)[-(1:7)]# 指定された効果量の種類
	labpos <- c(mainresults$mse.row, nrow(mainresults$anovatab))
	sourcelab <- rep(as.character(mainresults$anovatab$source.col[-labpos]), eslen)# 効果のラベル
	es.sample <- unlist(mainresults$anovatab[-labpos, -(1:7)])
	essamlen <- length(es.sample)/eslen# 主分析の出力効果量の個数
	es.sample <- array(es.sample, c(eslen * essamlen, 1))
	eslab <- rep(estype, each = essamlen)# 効果量のラベル
	internal.lab <- mainresults$internal.lab
	dmat <- mainresults$dmat
	flev <- mainresults$flev
	cellN <- mainresults$cellN
	full.elem <- mainresults$full.elem
	epsi.effect <- mainresults$epsi.effect
	if(auto){
		autov <- list((mainresults$epsitab$p >= 0.10)[min(withlen, 2):nrow(mainresults$epsitab)])# autoオプションの結果を引き継ぐためのベクトル
	}else{
		autov <- NULL
	}

	sig.source <- names(postresults)
	int.sig.source <- sig.source[nchar(sig.source) == 3]# 一次の交互作用のみ残す
	if(length(int.sig.source) > 0){# 一次の交互作用がみられた場合
		sim.dmat <- lapply(int.sig.source, function(x) postresults[[x]]$sim.dmat)
		sim.flev <- lapply(int.sig.source, function(x) postresults[[x]]$sim.flev)
		sim.cellN <- lapply(int.sig.source, function(x) postresults[[x]]$sim.cellN)
		postype <- lapply(int.sig.source, function(x) sum(is.na(postresults[[x]]$simepsi)) == 1)# 被験者間効果にはTRUE
		simtabs <- lapply(int.sig.source, function(x) postresults[[x]]$simtab)# 分散分析表を取り出す
		simsource <- mapply(function(x, y){if(x) y[-nrow(y), 1] 
			else y[-(2 * 1:(nrow(y)/2)), 1]}, postype, simtabs, SIMPLIFY = FALSE)
		es.sims <- unlist(mapply(function(x, y){if(x) y[-nrow(y), -(1:7)] 
			else y[-(2 * 1:(nrow(y)/2)), -(1:7)]}, postype, simtabs, SIMPLIFY = FALSE))
		es.sims <- array(es.sims, c(length(es.sims), 1))
		es.sample <- rbind(es.sample, es.sims)
		essimlen <- sapply(simsource, length)# 単純主効果の出力効果量の個数
		sourcelab <- c(sourcelab, unlist(lapply(simsource, function(x) rep(x, eslen))))
		eslab <- c(eslab, unlist(lapply(essimlen, function(x) rep(estype, each = x))))
		essamlen <- c(essamlen, essimlen)
		if(auto) autov <- c(autov, lapply(int.sig.source, function(x) postresults[[x]]$simepsi$p >= 0.10))
	}else{# 有意な一次の交互作用がない場合
		sim.dmat <- NULL
		sim.flev <- NULL
		sim.cellN <- NULL
		essimlen <- 0
	}

	# ブートストラップ用のデータの準備
	gmat <- array(t(sapply(uniq.s, function(x) (1:nrow(dat))[dat$s == x])), c(cellN, nrow(dat)/cellN))
	if(betlen == 0){
		gmat <- list(gmat)
	}else{
		gsep <- as.numeric(interaction(dat[sort(uniq.s), (betlen+1):2]))
		gmat <- lapply(unique(gsep), function(x) gmat[gsep == x, , drop = FALSE])
	}
	dpart <- dat[, -(maxfact+2)]

	# ブートストラップ処理
	bootdat <- lapply(1:B, function(w) cbind(dpart, y = dat$y[as.vector(do.call(rbind, lapply(gmat, function(x) x[sample(nrow(x), 
		replace = TRUE), , drop = FALSE])))]))
	stm <- Sys.time()# ブートストラップの開始時間
	if(.Platform$GUI == "Rgui"){# WindowsのRguiの場合（プログレスバーなし）
		bootresults <- do.call(cbind, lapply(1:B, function(v) {
			boot.anova(dat = bootdat[[v]], design = design, factnames = factnames, type2 = type2, dmat = dmat, flev = flev, 
				cellN = cellN, full.elem = full.elem, epsi.effect = epsi.effect, internal.lab = internal.lab, 
				int.sig.source = int.sig.source, sim.dmat = sim.dmat, sim.flev = sim.flev, sim.cellN = sim.cellN, 
				lb = lb, gg = gg, hf = hf, cm = cm, autov = autov, mau = mau, har = har, iga = iga, ciga = ciga, 
				eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, 
				pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep)
			}))
		cat("\n", as.numeric(Sys.time() - stm, units = "secs"), " secs elapsed for bootstrapping.", "\n", "\n", sep = "")
	}else{# その他のIDEの場合（プログレスバーを表示）
		cat("Now Bootstrapping...", "\n")
		bootresults <- do.call(cbind, lapply(1:B, function(v) {
			if(v %% (B/20) == 0) cat("|", rep("=", ceiling(v/(B/50))), rep(" ", 50 - ceiling(v/(B/50))), "| ", 2 * v/(B/50), "%", "\n", sep = "");
			boot.anova(dat = bootdat[[v]], design = design, factnames = factnames, type2 = type2, dmat = dmat, flev = flev, 
				cellN = cellN, full.elem = full.elem, epsi.effect = epsi.effect, internal.lab = internal.lab, 
				int.sig.source = int.sig.source, sim.dmat = sim.dmat, sim.flev = sim.flev, sim.cellN = sim.cellN, 
				lb = lb, gg = gg, hf = hf, cm = cm, autov = autov, mau = mau, har = har, iga = iga, ciga = ciga, 
				eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, 
				pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep)
			}))
		cat("\n", "Completed! ", as.numeric(Sys.time() - stm, units = "secs"), " secs elapsed.", "\n", "\n", sep = "")
	}

	# ジャックナイフ処理
	jkresults <- do.call(cbind, lapply(uniq.s, function(x) boot.anova(dat = dat[dat$s != x, ], design = design, 
		factnames = factnames, type2 = type2, flev = flev, cellN = cellN-1, full.elem = full.elem, epsi.effect = epsi.effect, 
		internal.lab = internal.lab, int.sig.source = int.sig.source, lb = lb, gg = gg, hf = hf, cm = cm, autov = autov, 
		mau = mau, har = har, iga = iga, ciga = ciga, eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, 
		omega = omega, omegana = omegana, pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep)))
	jkmeans <- rowMeans(jkresults, na.rm = TRUE)

	# BCa法のための統計量の計算
	bca.z0 <- qnorm(rowSums(bootresults < as.vector(es.sample), na.rm = TRUE) / B)
	bca.a <- rowSums((jkmeans - jkresults)^3, na.rm = TRUE) / (6 * rowSums((jkmeans - jkresults)^2, na.rm = TRUE)^(3/2))
	bca.ci.low <- pnorm(bca.z0 + (bca.z0 + qnorm((1 - conf.level)/2)) / (1 - bca.a * (bca.z0 + qnorm((1 - conf.level)/2))))
	bca.ci.up <- pnorm(bca.z0 + (bca.z0 + qnorm((1 + conf.level)/2)) / (1 - bca.a * (bca.z0 + qnorm((1 + conf.level)/2))))

	# 出力にまとめる
	bescitab <- data.frame("ES" = eslab, "Source" = sourcelab, "Observed" = es.sample, 
		"CI_L" = sapply(1:length(bca.ci.low), function(x) quantile(bootresults[x, ], bca.ci.low[x], na.rm = TRUE)), 
		"CI_U" = sapply(1:length(bca.ci.up), function(x) quantile(bootresults[x, ], bca.ci.up[x], na.rm = TRUE)), 
		"Bias" = rowMeans(bootresults, na.rm = TRUE) - es.sample, "S.E." = apply(bootresults, 1, sd), row.names = NULL)
	bescitab <- split(bescitab, rep(1:length(essamlen), eslen * essamlen))
	besci.info1 <- c("=== Bias-Corrected and Accelerated (BCa) Confidence Intervals for ESs ===", 
		paste0("=== ", 100 * conf.level, "% confidence intervals based on ", B, " replications ==="))
	minN <- min(table(dat[, 2:(maxfact+1)]))
	if(minN < 5){# サンプルサイズが小さすぎる場合に警告
		besci.info1 <- c(besci.info1, "*** CAUTION! The results may be INVALID because of too small sample size (n < 5). ***")
	}else if(minN < 20){
		besci.info1 <- c(besci.info1, "*** CAUTION! The results should be addressed CAREFULLY because of small sample size (n < 20). ***")
	}
	if(interim){# 中間結果を出力する場合
		return(list("besci.info" = besci.info1, "bescitab" = bescitab, "bootresults" = bootresults))
	}else{
		return(list("besci.info" = besci.info1, "bescitab" = bescitab))
	}
}


# 主分析と単純主効果の検定の効果量を一括して計算する関数
# 必須変数：dat，design，internal.lab，int.sig.source，少なくともひとつの効果量の指標
boot.anova <- function(dat, design, factnames = NA, type2 = FALSE, dmat = NULL, flev = NULL, cellN = NULL, full.elem = NA, 
	epsi.effect = NA, sim.dmat = NULL, sim.flev = NULL, sim.cellN = NULL, mainresults = NA, postresults = NA, internal.lab = NA, 
	int.sig.source = NA, lb = FALSE, gg = FALSE, hf = FALSE, cm = FALSE, autov = NULL, mau = FALSE, har = FALSE, 
	iga = FALSE, ciga = FALSE, eta = FALSE, peta = FALSE, geta = NA, eps = FALSE, peps = FALSE, geps = NA, omega = FALSE, 
	omegana = FALSE, pomega = FALSE, gomega = NA, gomegana = NA, prep = FALSE){
	bet.with <- strsplit(design, "s")[[1]]
	maxfact <- nchar(design) - 1
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数
	if(is.null(flev)) flev <- sapply(2:nchar(design), function(x) length(unique(dat[, x])))# 各要因の水準数

	esmain <- anova.modeler(dat = dat, design = design, factnames = factnames, type2 = type2, dmat = dmat, flev = flev, cellN = cellN, 
		full.elem = full.elem, epsi.effect = epsi.effect, lb = lb, gg = gg, hf = hf, cm = cm, auto = auto, autov = autov[[1]], 
		mau = mau, har = har, iga = iga, ciga = ciga, eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, 
		omega = omega, omegana = omegana, pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep, esboot = TRUE)

	if(length(int.sig.source) > 0){# 検討したい単純主効果がある場合
		esposts <- lapply(1:length(int.sig.source), function(x) boot.inter(dat = dat, design = design, factnames = factnames, 
			sig.term = int.sig.source[x], bet.with = bet.with, esmain = esmain, type2 = type2, flev = flev, 
			sim.dmat = sim.dmat[[x]], sim.flev = sim.flev[[x]], sim.cellN = sim.cellN[[x]], internal.lab = internal.lab, 
			lb = lb, gg = gg, hf = hf, cm = cm, autov = autov[[x+1]], mau = mau, har = har, iga = iga, ciga = ciga, 
			eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, 
			pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep))
	}else{# 検討したい単純主効果がない場合
		esposts <- NULL
	}

	esmat <- c(esmain$eslist, unlist(esposts))
	return(esmat)
}


# 単純主効果の検定の効果量のみを計算する関数
boot.inter <- function(dat, design, factnames = NA, type2 = FALSE, dmat = NULL, flev = NULL, cellN = NULL, full.elem = NA, epsi.effect = NA, 
	sim.dmat = NULL, sim.flev = NULL, sim.cellN = NULL, esmain = NA, sig.term = NA, bet.with = NA, internal.lab = NA, 
	lb = FALSE, gg = FALSE, hf = FALSE, cm = FALSE, autov = autov, mau = FALSE, har = FALSE, iga = FALSE, ciga = FALSE, 
	eta = FALSE, peta = FALSE, geta = NA, eps = FALSE, peps = FALSE, geps = NA, omega = FALSE, omegana = FALSE, pomega = FALSE, 
	gomega = NA, gomegana = NA, prep = FALSE){
	maxfact <- nchar(design) - 1# 実験計画全体における要因数
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数

	# 分析する要因の特定
	each.term <- strsplit(sig.term, ":")[[1]]
	targetnm <- sapply(each.term, function(x) grep(x, LETTERS[1:maxfact]))# 分割する要因が主分析で何番目の要因に当たるかを表すベクトル
	rtargetnm <- sort(targetnm, decreasing = TRUE)# 逆順にしたもの
	desnm <- c(betlen, withlen)# オリジナルのデザインの被験者間・被験者内の要因数
	sublevn <- lapply(LETTERS[rtargetnm], function(x) desnm - diag(2)[grep(x, bet.with), ])# 単純主効果の検定での被験者間・被験者内の要因数
	subdesign <- sapply(sublevn, function(x) paste0(paste0(LETTERS[min(1, x[1]):x[1]], collapse = ""), "s", 
		paste0(LETTERS[(x[2] != 0) * (x[1]+1):sum(x)], collapse = "")))# 単純主効果の検定のデザイン
	subdesign <- rep(subdesign, flev[rtargetnm])# ターゲット要因の水準数だけ繰り返す

	# データフレームの分割
	nmline <- rep(rtargetnm, flev[rtargetnm])# ターゲット要因の位置情報を水準数だけ繰り返す（逆順）
	tfline <- rep(targetnm, flev[rtargetnm])# 要因の順に位置情報を繰り返したベクトル
	subline <- unlist(lapply(rtargetnm + 1, function(x) split(x = seq_len(nrow(dat)), dat[, x])), recursive = FALSE)
	subdat <- mapply(function(x, y) dat[x, -y], subline, nmline + 1, SIMPLIFY = FALSE)
	interlab <- rep(LETTERS[targetnm - 0:1], flev[rtargetnm])
	simtimes <- length(nmline)# 単純主効果の検定の実行回数
	if(!is.null(autov)) c(rep(T, simtimes - length(autov)), autov)

	# 分割したデータフレームのヘッダを付け直す
	for(i in 1:simtimes){
		names(subdat[[i]]) <- c("s", LETTERS[1:(maxfact-1)], "y")
	}

	if(withlen == 0){# 被験者間計画の場合，主分析から情報を引き継ぐ
		bet.mse <- esmain$bet.mse
		gss.qT <- esmain$ss.qT
		anlefpos <- match(LETTERS[tfline], internal.lab)
		if(!is.null(esmain$esdenomis)){# 効果量算出の際の分母
			post.esdenomis <- esmain$esdenomis[anlefpos, , drop = FALSE]
		}

		# 検定の実行
		sim.effects <- lapply(1:simtimes, function(x) anova.modeler(dat = subdat[[x]], design = subdesign[x], 
			factnames = factnames[-nmline[x]], type2 = type2, dmat = sim.dmat[[x]], flev = sim.flev[[x]], cellN = sim.cellN[x], 
			eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, 
			pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep, inter = interlab[x], bet.mse = bet.mse, 
			gss.qT = gss.qT, post.esdenomis = post.esdenomis[x, , drop = FALSE], esboot = TRUE))
		simes <- as.vector(do.call(rbind, sim.effects))
	}else{# 反復測定要因を含む場合
		# 検定の実行
		sim.effects <- lapply(1:simtimes, function(x) anova.modeler(dat = subdat[[x]], design = subdesign[x], 
			factnames = factnames[-nmline[x]], type2 = type2, dmat = sim.dmat[[x]], flev = sim.flev[[x]], cellN = sim.cellN[x], 
			lb = lb, gg = gg, hf = hf, cm = cm, autov = autov[x], mau = mau, har = har, iga = iga, ciga = ciga, 
			eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, omega = omega, omegana = omegana, 
			pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep, inter = interlab[x], esboot = TRUE))
		simes <- as.vector(do.call(rbind, sim.effects))
	}

	return(simes)
}


# 出力の種類ごとに設定を割り当てる関数
anova.output <- function(maxfact, exe.info, baseresults, mainresults, postresults = NA, sep = " "){
	# 実行情報の出力
	cat("\n")
	cat(sprintf(exe.info[1]), sep = "\n")
	cat("\n")
	cat(sprintf(exe.info[2:3]), sep = "\n")
	cat("\n", "\n")

	# 記述統計量の出力
	bstat.title	<- "<< DESCRIPTIVE STATISTICS >>"
	bstat.info1 <- baseresults$bstat.info1
	bstatist <- baseresults$bstatist
	bstat.info2 <- baseresults$bstat.info2
	pairtab <- baseresults$pairtab
	flev <- mainresults$flev
	if(maxfact < 3){# 改行位置の指定
		margin <- prod(flev)
	}else{
		margin <- prod(flev[-(1:(maxfact-2))])
	}
	table.out(bstatist, titleinfo = bstat.title, subinfo1 = bstat.info1, smargin = margin, rndpos = maxfact + 1, sep = sep)
	if(!is.null(pairtab)){# ペアワイズ信頼区間を出力する場合
		table.out(pairtab, subinfo1 = bstat.info2, sep = sep)
	}
	cat("\n")

	# 球面性の指標の出力
	epsitab.title <- "<< SPHERICITY INDICES >>"
	epsi.info1 <- mainresults$epsi.info1
	epsitab <- mainresults$epsitab
	epsi.header <- names(epsitab)
	epsi.header[6] <- ""
	if(!is.na(epsi.info1)){# 球面性の指標を出力する場合
		if(match("GG", names(epsitab), nomatch = 0) != 0){
			epsi.info2 <- c("LB = lower.bound, GG = Greenhouse-Geisser", "HF = Huynh-Feldt-Lecoutre, CM = Chi-Muller")
			epsi.margin <- nrow(epsitab)
		}else{
			epsi.info2 <- "multiplier = b_hat or c_hat"
			epsi.margin <- c(anyNA(epsitab$df) * (1:nrow(epsitab))[!is.na(epsitab$df)] - 1, nrow(epsitab))
		}
		table.out(epsitab, titleinfo = epsitab.title, subinfo1 = epsi.info1, subinfo2 = epsi.info2, lmargin = epsi.margin, 
			use.header = epsi.header, tnick = 0, rndpos = 4, strpos = c(1, 4), na.erase = 5, leftal = 6, sep = sep)
		cat("\n")
	}

	# 分散分析表の出力
	anovatab.title <- "<< ANOVA TABLE >>"
	ano.info1 <- mainresults$ano.info1
	ano.info2 <- "+p < .10, *p < .05, **p < .01, ***p < .001"
	anovatab <<- mainresults$anovatab
	forDrawingPost <<- postresults
	forDrawingSigANOVA <<- mainresults$anovatab
	
	ano.header <- names(anovatab)
	ano.header[1:7] <- c("Source", "SS", "df", "MS", "F-ratio", "p-value", "")
	mse.row <- mainresults$mse.row
	nesci.info1 <- mainresults$nesci.info1
	nescitab <- mainresults$nescitab
	if(length(ano.header) > 7){# 効果量を出力する場合は文字の間隔を狭める
		ano.nick <- 0
		ano.erase <- c(5:6, 8:length(ano.header))
	}else{
		ano.nick <- 1
		ano.erase <- 5:6
	}
	table.out(anovatab, titleinfo = anovatab.title, subinfo1 = ano.info1, subinfo2 = ano.info2, use.header = ano.header, 
		lmargin = mse.row, tnick = ano.nick, rndpos = 3, na.erase = ano.erase, leftal = 7, sep = sep)
	cat("\n")
	if(!anyNA(nesci.info1)){# 非心分布に基づく効果量の信頼区間を出力する場合
		esci.title <- "<< EFFECT SIZE INFORMATION >>"
		efrowsize <- nrow(anovatab) - length(mse.row) - 1
		table.out(nescitab, titleinfo = esci.title, subinfo1 = nesci.info1, lmargin = efrowsize * 1:(nrow(nescitab)/efrowsize), 
			sep = sep)
		cat("\n")
	}
	if(match("bescitab", names(mainresults), nomatch = 0) != 0){# ブートストラップに基づく効果量の信頼区間を出力する場合
		if(!anyNA(nesci.info1)){
			esci.title <- NULL
		}else{
			esci.title <- "<< EFFECT SIZE INFORMATION >>"
		}
		efrowsize <- nrow(anovatab) - length(mse.row) - 1
		table.out(mainresults$bescitab, titleinfo = esci.title, subinfo1 = mainresults$besci.info, 
			lmargin = efrowsize * 1:(nrow(mainresults$bescitab)/efrowsize), sep = sep)
		cat("\n")
	}

	# 下位検定の結果の出力
	postnum <- length(postresults)# リストに含まれる要素の数を特定
	# 少なくともひとつのNAでない要素があれば，セクションタイトルを表示する
	if(sum(is.na(postresults)) != postnum){
		cat(sprintf("<< POST ANALYSES >>"), sep = "", "\n", "\n")# タイトル
	}
	postnames <- names(postresults)
	for(i in 1:postnum){
		if(is.na(postresults[[i]][1])){# 何もない場合（２水準の主効果が有意で多重比較の必要なしの場合）
		}else if(nchar(postnames[i]) == 1){# 多重比較の結果がある場合
			mod.Bon.out(postresults[[i]], sep = sep)
			cat("\n")# １行空ける
		}else if(nchar(postnames[i]) == 3){# 一次の交互作用が見られた場合
			if(maxfact == 2){
				simeffects.out(postresults[[i]], epsi.info2 = epsi.info2, epsi.header = epsi.header, ano.info2 = ano.info2, 
					ano.header = ano.header, ano.nick = ano.nick, ano.erase = ano.erase, omit = TRUE, sep = sep)
			}else{
				simeffects.out(postresults[[i]], epsi.info2 = epsi.info2, epsi.header = epsi.header, ano.info2 = ano.info2, 
					ano.header = ano.header, ano.nick = ano.nick, ano.erase = ano.erase, sep = sep)
			}
		}else if(nchar(postnames[i]) >= 5){# 高次の交互作用が見られた場合
			cat(sprintf(paste0("< HIGHER-ORDER \"", postresults[[i]][[1]], "\" INTERACTION >")),sep = "", "\n")
			cat(sprintf("*** Split the dataset for further analysis. ***"), sep ="", "\n", "\n")# データ分割を促すプロンプト
		}
	}

	# 終了メッセージ
	cat(sprintf("output is over "), sprintf(rep("-", 20)), sprintf("///"), sep = "", "\n", "\n")
}


# データフレームに書式を与えて出力する関数
# smargin：空白を挿入する行，lmargin：ラインを挿入する行，tnick：表中の文字間隔，rndpos：桁数を縮めて表示する列
# strpos：文字列として表示する列，na.erase：NAを表示させない列，leftal：左寄せする列
table.out <- function(dattable, titleinfo = NULL, subinfo1 = NULL, subinfo2 = NULL, use.header = NULL, smargin = nrow(dattable), 
	lmargin = nrow(dattable), tnick = 1, rndpos = 0, strpos = rndpos, na.erase = NULL, leftal = NULL, sep = " "){
	# ヘッダとテーブル本体の要素の表示マージンを決定する
	tabline <- pmax(3, sapply(1:ncol(dattable), function(x) ifelse(is.numeric(dattable[, x]), max(nchar(sprintf("%.4f", dattable[, x]), type = "width")), max(nchar(as.character(dattable[, x]), type = "width")))) + tnick)
	if(is.null(use.header)){# データフレームのヘッダをそのまま使う場合
		tabhead <- nchar(names(dattable)) + 1
	}else{# 指定された文字列を使う場合
		tabhead <- nchar(use.header) + 1
	}
	tabline <- ifelse(tabline > tabhead, tabline, tabhead)
	if(rndpos != 0){
		dattable[, rndpos] <- round(dattable[, rndpos], 2)# 小数部分がある場合は，小数点以下二桁まで
		tabline[rndpos] <- pmax(3, max(nchar(dattable[, rndpos])), na.rm = TRUE)
	}
	mainline <- sum(tabline) + length(tabline)
	headmargin <- sapply(tabline, function(x) paste0("%", x, "s"))
	bodymargin <- headmargin
	coltype <- sapply(1:ncol(dattable), function(x) is.factor(dattable[, x]) | is.character(dattable[, x]))# 各列がfactor型か文字型ならチェック	
	coltype[strpos] <- TRUE# 指定された列については，数値型でも文字列として出力
	bodymargin[!coltype] <- paste0("%", tabline[!coltype], ".4f")# factor型・文字型でないところは数値型で出力
	bodymargin[leftal] <- gsub("%", "%-", bodymargin[leftal])# 左寄せを指定する列

	# タイトルを表示する
	if(!is.null(titleinfo)){# titleinfoがNULLでなければ表示
		cat(sprintf(titleinfo), sep = "", "\n")
		cat("\n")# １行空ける
	}
	if(!is.null(subinfo1)){# subinfo1がNULLでなければ表示
		cat(subinfo1, sep = "\n")# プロンプトを表示
		cat("\n")# １行空ける
	}

	# データフレームのヘッダ部分を表示する
	cat(sprintf(rep("-", mainline + 2)), sep = "", "\n")# ラインを引く；要因の数に合わせて長さを調整
	if(is.null(use.header)){
		cat(sprintf(headmargin, names(dattable)), sep = sep, "\n")# データフレームの列名を表示する
	}else{
		cat(sprintf(headmargin, use.header), sep = sep, "\n")# 指定された文字列をヘッダとして表示する
	}
	cat(sprintf(rep("-", mainline + 2)), sep = "", "\n")

	# データフレームのデータ部分を一行ずつ表示する
	for (i in 1:nrow(dattable)){# 行ごとの処理
		for(j in 1:ncol(dattable)){# 列ごとの処理
			if(is.element(j, na.erase)){# 指定があった列では，NAを空白に置き換えて表示する
				cat(replace(sprintf(bodymargin[j], dattable[i, j]), is.na(dattable[i, j]), sprintf(headmargin[j], "")))
			}else{
				cat(sprintf(bodymargin[j], dattable[i, j]))
			}
			cat(sep, sep = "")
		}
		cat("\n")
		if(is.element(i, lmargin)){# ラインを引く
			cat(sprintf(rep("-", mainline + 2)), sep = "", "\n")
		}
		if((i %% smargin == 0) && (i != nrow(dattable))){# 一行空ける
			cat("\n")
		}
	}
	if(!is.null(subinfo2)){# subinfo2がNULLでなければ表示
		cat(sprintf(paste0("%", mainline, "s"), subinfo2), sep = "\n")# プロンプトを表示
	}
	cat("\n")# １行空ける
}


# 修正Bonferroniの方法による多重比較の結果を出力する関数
mod.Bon.out <- function(bon.list, omit = FALSE, sep = " "){
	# 情報を展開
	factlabel <- bon.list[[1]]
	bon.info1 <- bon.list[[2]]
	bon.info2 <- bon.list[[3]]
	bon.info3 <- bon.list[[4]]
	bonstat <- bon.list[[5]]
	bontab <- bon.list[[6]]
	Bon.header <- c("Pair", "Diff", "t-value", "df", "p", "adj.p", "")

	cat(sprintf(paste0("< MULTIPLE COMPARISON for \"", factlabel, "\" >")), sep = "", "\n", "\n")# タイトル
	cat(sprintf(bon.info1), sep = "\n")# プロンプト
	cat(sprintf(bon.info2), "\n")
	cat(sprintf(bon.info3), "\n", "\n")

	# omitがFALSEなら記述統計量を出力する
	if(!omit){
		table.out(bonstat, rndpos = 2, sep = sep)
	}

	# 多重比較の結果を表形式で出力する
	table.out(bontab, use.header = Bon.header, rndpos = 4, strpos = c(1, 4), sep = sep)
}


# 単純主効果の検定の結果を出力する関数
simeffects.out <- function(partresult, epsi.info2 = NA, epsi.header = NA, ano.info2 = NA, ano.header = NA, ano.nick = NA, 
	ano.erase = NA, omit = FALSE, sep = " "){
	# 情報を展開
	part.info1 <- partresult[[1]]
	partstat <- partresult$sim.stat
	partepsi <- partresult$simepsi
	parttab <- partresult$simtab
	partmulttab <- partresult$sim.multresults
	partnesci <- partresult$simnesci

	cat(sprintf("%s", paste0("< SIMPLE EFFECTS for \"", part.info1, "\" INTERACTION >"), sep = ""), sep = "", "\n", "\n")# タイトル

	# omitがFALSEなら記述統計量を出力する
	if(!omit){
		table.out(partstat, rndpos = 3, sep = sep)
	}

	# 球面性検定の結果を出力
	if(is.na(charmatch("Error", parttab$source.col)) && !is.na(partepsi)){
		# 被験者内計画，混合要因計画なら球面性検定の結果を出力する
		table.out(partepsi, subinfo2 = epsi.info2, use.header = epsi.header, tnick = c(1, rep(0, length(epsi.header) - 1)), 
			rndpos = 4, strpos = c(1, 4), na.erase = 5, leftal = 6, sep = sep)
		efrowsize <- nrow(parttab)/2
		linepos <- 2 * 1:(nrow(parttab)/2)
	}else{
		efrowsize <- nrow(parttab) - 1
		linepos <- nrow(parttab)
	}

	# 分散分析表を出力
	table.out(parttab, subinfo2 = ano.info2, use.header = ano.header, lmargin = linepos, tnick = ano.nick, rndpos = 3, 
		strpos = c(1, 3), na.erase = ano.erase, leftal = 7, sep = sep)
	if(!all(is.na(partnesci))){# 非心分布に基づく効果量の信頼区間を出力する場合
		table.out(partnesci, lmargin = efrowsize * 1:(nrow(partnesci)/efrowsize), strpos = 2, sep = sep)
		cat("\n")
	}
	if(match("bescitab", names(partresult), nomatch = 0) != 0){# ブートストラップに基づく効果量の信頼区間を出力する場合
		table.out(partresult$bescitab, lmargin = efrowsize * 1:(nrow(partresult$bescitab)/efrowsize), strpos = 2, sep = sep)
		cat("\n")
	}

	# 多重比較の結果を出力する
	for (i in 1:length(partmulttab)){
		if(!is.na(partmulttab[[i]][1])){# リストに中身があったら出力する
			cat("\n")# １行空ける
			mod.Bon.out(partmulttab[[i]], omit = TRUE, sep = sep)
		}
	}
}


# 指定した要因についてデータを分割して単純効果の検定を行う関数；３要因以上の計画での使用を想定
# tfactの引数として分割の基準とする要因のラベルを指定する（tfact = "A"など）
# 同時に複数の要因について分割する場合，tfact = c("A", "C")のような形式で入力する
anovatan <- function(dataset, design, ..., tfact = NULL, long = FALSE, type2 = FALSE, nopost = FALSE, tech = FALSE, data.frame = FALSE, copy = FALSE, 
	holm = FALSE, hc = FALSE, s2r = FALSE, s2d = FALSE, fs1 = FALSE, fs2r = FALSE, fs2d = FALSE, welch = FALSE, criteria = FALSE, 
	lb = FALSE, gg = FALSE, hf = FALSE, cm = FALSE, auto = FALSE, mau = FALSE, har = FALSE, iga = FALSE, ciga = FALSE, 
	eta = FALSE, peta = FALSE, geta = NA, eps = FALSE, peps = FALSE, geps = NA, omega = FALSE, omegana = FALSE, pomega = FALSE, 
	gomega = NA, gomegana = NA, prep = FALSE, nesci = FALSE, besci = FALSE, cilmd = FALSE, cilm = FALSE, cind = FALSE, cin = FALSE, ciml = FALSE, 
	cipaird = FALSE, cipair = FALSE, bgraph = c(NA, NA)){
	# 分割する要因が指定されていない場合は終了
	if(is.null(tfact)){
		stop(message = "\"anovatan\" has stopped working...\nPlease specify some factors to split.")
	}

	# 要因計画情報の取得
	maxfact <- nchar(design) - 1# 実験計画全体における要因数
	bet.with <- strsplit(design, "s")[[1]]
	spos <- match("s", strsplit(design, "")[[1]], nomatch = 0)
	betlen <- spos - 1# 被験者間要因の数
	withlen <- maxfact - spos + 1# 被験者内要因の数

	# データフレームの変形
	datform <- uni.long(dataset = dataset, design = design, ... = ..., long = long)
	dat <- datform$dat
	factnames <- datform$factnames
	miscase <- datform$miscase
	names(dat) <- c("s", factnames, "y")
	targetnm <- sapply(tfact, function(x) grep(x, factnames))# 分割する要因が主分析で何番目の要因に当たるかを表すベクトル

	# データと要因計画の準備
	subdat <- split(dat, dat[, tfact])# データフレームを分割
	whichfact <- sapply(LETTERS[targetnm], function(x) grep(x, bet.with))# 分割する要因が被験者間要因と被験者内要因のどちらに属するのかを表すベクトル
	bet.withN <- c(betlen, withlen) - c(sum(whichfact == 1), sum(whichfact == 2))# 下位検定における被験者間要因・被験者内要因の数を表すベクトル
	subdesign <- paste0(paste0(LETTERS[(1 * (bet.withN[1] != 0)):bet.withN[1]], collapse = ""), "s", paste0(LETTERS[1 * (bet.withN[2] != 0) * (bet.withN[1]+1:bet.withN[2])], collapse = ""))# 下位検定の計画の型

	# copyオプションの指定があった場合，出力をクリップボードにコピー
	if(copy){
		plat.info <- .Platform
		if(sum(grep("windows", plat.info)) != 0){# Windowsの場合
			sink("clipboard", split = TRUE)
		}else if(sum(grep("mac", plat.info)) != 0){# Macの場合
			tclip <- pipe("pbcopy", "w")
			sink(tclip, split = TRUE)
		}else if(sum(grep("linux", R.version$system)) != 0){# Linuxの場合（xclipをインストールしている必要がある）
			tclip <- pipe("xclip -selection clipboard")
			sink(tclip, split = TRUE)
		}
	}

	# 除外したケースの報告
	if(miscase != 0){
		cat("[[ Information for Whole Analysis ]]", "\n")
		cat(paste0("== The number of removed case is ", miscase, ". =="), "\n", "\n")
	}

	# anovakunの実行
	for(i in 1:length(subdat)){
		cat("\n", sprintf(paste0("[[ Simple Effects for ", names(subdat)[i], " ]]")), "\n", sep = "")
		anovakun(dataset = subdat[[i]][, -(targetnm + 1)], design = subdesign, long = TRUE, type2 = type2, nopost = nopost, 
			tech = tech, data.frame = FALSE, copy = FALSE, holm = holm, hc = hc, s2r = s2r, s2d = s2d, fs1 = fs1, fs2r = fs2r, 
			fs2d = fs2d, welch = welch, criteria = criteria, lb = lb, gg = gg, hf = hf, cm = cm, auto = auto, mau = mau, 
			har = har, iga = iga, ciga = ciga, eta = eta, peta = peta, geta = geta, eps = eps, peps = peps, geps = geps, 
			omega = omega, omegana = omegana, pomega = pomega, gomega = gomega, gomegana = gomegana, prep = prep, nesci = nesci, besci = besci, 
			cilmd = cilmd, cilm = cilm, cind = cind, cin = cin, ciml = ciml, cipaird = cipaird, cipair = cipair, bgraph = bgraph)
	}

	# copyを実行していた場合，クリップボードを閉じる
	if(copy){
		sink()
		if(plat.info$OS.type != "windows"){# Mac，Linuxの場合
			close(tclip)
		}
	}

	# 指定があった場合は，分割後のデータフレームを出力
	if(data.frame == TRUE){
		return(subdat)
	}
}

