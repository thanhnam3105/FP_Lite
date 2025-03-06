/*******************************************/
/* 定数定義ファイル：英語版                  */
/*******************************************/
(function () {
    App.ui.pagedata.lang("vi", {
        // 定数定義
        underBar: { text: "_" },
        kakkoL: { text: "(" },
        kakkoR: { text: ")" },
        requiredMark: { text: "*" },
        colon: { text: "：" },
        //add tooltip
        addTooltip: { text: true },

        // TODO:区分コードを記入します 
        // 【取引先区分】仕入品
        shiiresakiToriKbn: { text: "1" },
        // 【取引先区分】売上先
        uriagesakiToriKbn: { text: "2" },
        // 【取引先区分】製造元
        seizomotoToriKbn: { text: "3" },

        // 【品区分】製品
        seihinHinKbn: { text: "1" },
        // 【品区分】原料
        genryoHinKbn: { text: "2" },
        // 【品区分】資材
        shizaiHinKbn: { text: "3" },
        // 【品区分】配合
        haigoHinKbn: { text: "4" },
        // 【品区分】仕掛品
        shikakariHinKbn: { text: "5" },
        // 【品区分】前処理原料
        maeshoriGenryoHinKbn: { text: "6" },
        // 【品区分】自家原料
        jikaGenryoHinKbn: { text: "7" },
        // 【品区分】作業指示
        sagyoShijiHinKbn: { text: "8" },
        // 【品区分】その他
        sonotaHinKbn: { text: "9" },
        // 【品区分】未登録値
        hinKbnMitorokuchi: { text: "0" },

        // 【換算区分】Kg
        kgKanzanKbn: { text: "4" },
        // 【換算区分】L
        lKanzanKbn: { text: "11" },

        // 【在庫区分】良品
        ryohinZaikoKbn: { text: "1" },
        // 【在庫区分】保留品
        horyuZaikoKbn: { text: "2" },

        // 【単位コード】C/S
        caseCdTani: { text: "1" },
        // 【単位コード】Ｋｇ
        kgCdTani: { text: "4" },
        // 【単位コード】L
        lCdTani: { text: "11" },
        // 【単位コード】枚
        maiCdTani: { text: "15" },
        // 【単位コード】本
        honCdTani: { text: "16" },
        // 【単位コード】缶
        kanCdTani: { text: "21" },

        // 【フラグ】 FALSE
        falseFlg: { text: "0" },
        // 【フラグ】 TRUE
        trueFlg: { text: "1" },

        // 【未使用フラグ】 使用
        shiyoMishiyoFlg: { text: "0" },
        // 【未使用フラグ】 未使用
        mishiyoMishiyoFlg: { text: "1" },

        // 【確定フラグ】 未確定
        mikakuteiKakuteiFlg: { text: "0" },
        // 【確定フラグ】 確定
        kakuteiKakuteiFlg: { text: "1" },

        // 【製造ラインマスタ区分】 品名マスタ
        hinmeiMasterSeizoLineMasterKbn: { text: "1" },
        // 【製造ラインマスタ区分】 配合マスタ
        haigoMasterSeizoLineMasterKbn: { text: "2" },

        // 【状態区分】 固体(中国では紛体)
        kotaiJotaiKbn: { text: "1" },
        // 【状態区分】 液体
        ekitaiJotaiKbn: { text: "2" },
        // 【状態区分】 仕掛品
        shikakariJotaiKbn: { text: "3" },
        // 【状態区分】 半固体
        hankotaiJotaiKbn: { text: "4" },
        // 【状態区分】 その他
        sonotaJotaiKbn: { text: "9" },

        // 【理由区分】 調整理由
        choseiRiyuKbn: { text: "1" },
        // 【理由区分】 休日理由
        kyujitsuRiyuKbn: { text: "2" },

        // 【納入書形式区分】 納入数量
        suNonyuKeishikiKbn: { text: "1" },
        // 【納入書形式区分】 使用数量
        suShiyouKeishikiKbn: { text: "2" },

        // 【敬称区分】 様
        samaKeishoKbn: { text: "1" },
        // 【敬称区分】 御中
        onchuKeishoKbn: { text: "2" },
        // 【敬称区分】 なし
        nashiKeishoKbn: { text: "3" },

        // 【予実フラグ】 予定
        yoteiYojitsuFlg: { text: "0" },
        // 【予実フラグ】 実績
        jissekiYojitsuFlg: { text: "1" },

        // 【休日フラグ】 平日
        heijitsuKyujitsuFlg: { value: 0 },
        // 【休日フラグ】 休日
        kyujitsuKyujitsuFlg: { value: 1 },

        // 【品名マスタセレクタパラメータ】 品名マスタ選択
        maHinmeiHinDlgParam: { text: "1" },
        // 【品名マスタセレクタパラメータ】 原料仕掛品選択
        genryoShikakariHinDlgParam: { text: "2" },
        // 【品名マスタセレクタパラメータ】 レシピ登録用選択
        recipeTorokuHinDlgParam: { text: "3" },
        // 【品名マスタセレクタパラメータ】 製品選択
        seihinHinDlgParam: { text: "4" },
        // 【品名マスタセレクタパラメータ】 仕掛品選択
        shikakariHinDlgParam: { text: "5" },
        // 【品名マスタセレクタパラメータ】 原資材選択
        genshizaiHinDlgParam: { text: "6" },
        // 【品名マスタセレクタパラメータ】 原料選択
        genryoHinDlgParam: { text: "7" },
        // 【品名マスタセレクタパラメータ】 資材選択
        shizaiHinDlgParam: { text: "8" },
        // 【品名マスタセレクタパラメータ】 自家原料選択
        jikaGenryoHinDlgParam: { text: "9" },
        // 【品名マスタセレクタパラメータ】 作業指示選択
        sagyoShijiHinDlgParam: { text: "10" },
        // 【品名マスタセレクタパラメータ】 製品自家原料選択
        seihinJikagenHinDlgParam: { text: "11" },
        // 【品名マスタセレクタパラメータ】 原資材自家原選択
        genshizaiJikagenHinDlgParam: { text: "12" },
        // 【品名マスタセレクタパラメータ】 原資材自家原仕掛品選択
        genshizaiJikagenShikakariHinDlgParam: { text: "13" },
        // 【品名マスタセレクタパラメータ】 製品計画用
        keikakuSeihinHinDlgParam: { text: "14" },
        // 【品名マスタセレクタパラメータ】 仕掛品計画用
        keikakuShikakariDlgParam: { text: "15" },
        // 【品名マスタセレクタパラメータ】 製品自家原料仕掛品選択
        seihinShikakariDlgParam: { text: "16" },
        //【品名マスタセレクタパラメータ】
        genryoLotTorokuDlgParam: { text: "17" },

        // 【マークコード】　小分原料
        kowakeMarkCode: { text: "00" },
        // 【マーク】　重ね小分1
        kasane1MarkCode: { text: "01" },
        // 【マーク】　重ね小分2
        kasane2MarkCode: { text: "02" },
        // 【マーク】　重ね小分3
        kasane3MarkCode: { text: "03" },
        // 【マーク】　重ね小分4
        kasane4MarkCode: { text: "04" },
        // 【マーク】　重ね小分5
        kasane5MarkCode: { text: "05" },
        // 【マーク】　重ね小分6
        kasane6MarkCode: { text: "06" },
        // 【マーク】　重ね小分7
        kasane7MarkCode: { text: "07" },
        // 【マーク】　重ね小分8
        kasane8MarkCode: { text: "08" },
        // 【マーク】　重ね小分9
        kasane9MarkCode: { text: "09" },
        // 【マーク】　スパイス
        spiceMarkCode: { text: "10" },
        // 【マーク】　荷姿投入原料
        nisugataTonyuMarkCode: { text: "11" },
        // 【マーク】　攪拌
        kakuhanMarkCode: { text: "12" },
        // 【マーク】　表示
        hyojiMarkCode: { text: "13" },
        // 【マーク】　RI値
        RIMarkCode: { text: "14" },
        // 【マーク】　作業指示
        sagyoMarkCode: { text: "15" },
        // 【マーク】　流量計
        ryuryokeiMarkCode: { text: "16" },

        // 【マーク】　小分原料
        kowakeMarkKbn: { text: "" },
        // 【マーク】　重ね小分1
        kasane1MarkKbn: { text: "1" },
        // 【マーク】　重ね小分2
        kasane2MarkKbn: { text: "2" },
        // 【マーク】　重ね小分3
        kasane3MarkKbn: { text: "3" },
        // 【マーク】　重ね小分4
        kasane4MarkKbn: { text: "4" },
        // 【マーク】　重ね小分5
        kasane5MarkKbn: { text: "5" },
        // 【マーク】　重ね小分6
        kasane6MarkKbn: { text: "6" },
        // 【マーク】　重ね小分7
        kasane7MarkKbn: { text: "7" },
        // 【マーク】　重ね小分8
        kasane8MarkKbn: { text: "8" },
        // 【マーク】　重ね小分9
        kasane9MarkKbn: { text: "9" },
        // 【マーク】　スパイス
        spiceMarkKbn: { text: "P" },
        // 【マーク】　荷姿投入原料
        nisugataTonyuMarkKbn: { text: "N" },
        // 【マーク】　攪拌
        kakuhanMarkKbn: { text: "A" },
        // 【マーク】　表示
        hyojiMarkKbn: { text: "H" },
        // 【マーク】　RI値
        RIMarkKbn: { text: "R" },
        // 【マーク】　作業指示
        sagyoMarkKbn: { text: "S" },
        // 【マーク】　流量計
        ryuryokeiMarkKbn: { text: "L" },

        // 【ラベルコード】 重ねラベル
        kasaneLabelCd: { text: "9999998" },

        // 【重量加算区分】 %加算
        percentJuryoKasanKbn: { text: "1" },
        // 【重量加算区分】 g加算
        gramJuryoKasanKbn: { text: "2" },

        // 【税区分】外税
        sotoZeiKbn: { text: "0" },
        // 【税区分】内税
        uchiZeiKbn: { text: "1" },
        // 【税区分】非課税
        hikazeiZeiKbn: { text: "2" },

        // 【庫入区分】即庫入
        sokuKuraireKuraireKbn: { text: "1" },
        // 【庫入区分】未包装
        mihosoKuraireKbn: { text: "2" },
        // 【庫入区分】庫入なし
        kuraireNashiKuraireKbn: { text: "3" },

        // 【正規、端数区分】正規
        seikiHasuSeikiKbn: { text: "1" },
        // 【正規、端数区分】端数
        seikiHasuHasuKbn: { text: "2" },

        // 【受払区分】納入予定
        ukeharaiNounyuYoteiKbn: { text: "0" },
        // 【受払区分】納入実績
        ukeharaiNounyuJissekiKbn: { text: "1" },
        // 【受払区分】使用予定
        ukeharaiShiyoYoteiKbn: { text: "2" },
        // 【受払区分】使用実績
        ukeharaiShiyoJissekiKbn: { text: "3" },
        // 【受払区分】調整数
        ukeharaiChoseiKbn: { text: "4" },
        // 【受払区分】製造予定
        ukeharaiSeizoYoteiKbn: { text: "5" },
        // 【受払区分】製造実績
        ukeharaiSeizoJissekiKbn: { text: "6" },

        // 【処理品フラグ】なし
        nashiShorihinFlg: { text: "0" },
        // 【処理品フラグ】処理品
        shorihinShorihinFlg: { text: "1" },

        // 【仕上重量区分】自動計算の配合重量の合計
        totalHaigoQty: { text: "0" },
        // 【仕上重量区分】手入力
        shiagariQty: { text: "1" },

        // 【受信ステータス区分】未
        jushinStatusKbnMijushin: { text: "0" },
        // 【受信ステータス区分】済
        jushinStatusKbnSumi: { text: "1" },

        // 【資材使用マスタ：最大追加行数】
        maxAddRowCount: { text: 99 },

        // 【納入依頼書：PDF：1ページに表示する列数】
        pdfColMaximums5: { text: "5" },    // 横：5列
        pdfColMaximums2: { text: "2" },    // 縦：2列

        // 【風袋】荷姿風袋コード
        nisugataFutaiCode: { text: "00" }, 

        // 【品名コード】未登録値
        hinCodeMitorokuchi: { text: "-" },

        // 【使用実績按分区分】製造
        shiyoJissekiAnbunKubunSeizo: { text: "1" },
        // 【使用実績按分区分】調整
        shiyoJissekiAnbunKubunChosei: { text: "2" },
        // 【使用実績按分区分】残
        shiyoJissekiAnbunKubunZan: { text: "3" },

        // 【伝送状態区分】未作成
        densoJotaiKbnMisakusei: { text: "0" },
        // 【伝送状態区分】未伝送
        densoJotaiKbnMidenso: { text: "1" },
        // 【伝送状態区分】伝送待
        densoJotaiKbnDensomachi: { text: "2" },
        // 【伝送状態区分】伝送中
        densoJotaiKbnDensochu: { text: "3" },
        // 【伝送状態区分】伝送済
        densoJotaiKbnDensosumi: { text: "4" }, 

        // 【登録状態区分】未登録
        torokuJotaiKbnMitoroku: { text: "0" }, 
        // 【登録状態区分】一部未登録
        torokuJotaiKbnIchibuMitoroku: { text: "1" },
        // 【登録状態区分】登録済
        torokuJotaiKbnTorokusumi: { text: "2" },

        // 【テスト品フラグ】False
        flgTestItem: { number: 0 },
        // 【テスト品フラグ】True
        flgTestItem: { number: 1 },
                
        // 【小数点位置】2
        ketaShosuten2: { number: 2 },
        // 【小数点位置】3
        ketaShosuten3: { number: 3 },

        // 【小分計算区分】均等小分
        kbnKowakeFutaiKinto: { number: 1 },
        // 【小分計算区分】最大小分
        kbnKowakeFutaiSaidai: { number: 2 },

        //////////【機能区分】バージョンごとの機能区分及び値を設定します
        // 【機能区分】ラベルフォーマット
        kinoLabelKbn: { number: 1 },
        // ラベルフォーマット区分.現行用
        baseLabelFormatKbn: { number: 0 },
        // ラベルフォーマット区分.海外用
        kaigaiLabelFormatKbn: { number: 1 },
        // ラベルフォーマット区分.中文用
        chinaLabelFormatKbn: { number: 2 },

        // 【機能区分】単位区分
        kinoTaniKbn: { number: 2 },
        // 単位区分.Kg・L (デフォルト)
        kinoTaniKgLi: { number: 0 },
        // 単位区分.LB・GAL (アメリカ用)
        kinoTaniLbGal: { number: 1 },
        //【単位区分】Kg・L
        kbn_tani_Kg_L: { text:　"0" },
        //【単位区分】LB・GAL
        kbn_tani_LB_GAL: { text: "1" },

        // 【機能区分】日付自動計算区分(2014/12/24現在、荷受でしか使用していない)
        kinoKigenKbn: { number: 3 },
        // 日付自動計算区分.自動
        kigenAutoKbn: { number: 0 },
        // 日付自動計算区分.手動
        kigenManualKbn: { number: 1 },

        // 【機能区分】固定日区分
        kinoKoteibiKbn: { number: 4 },
        // 固定日区分.使用しない
        kbnKoteibiMishiyo: { number: 0 },
        // 固定日区分.使用する
        kbnKoteibiShiyo: { number: 1 },

        // 【機能区分】ロケーション区分
        kinoLocationKbn: { number: 5 },
        // ロケーション区分.なし
        locationKbn_nasi: { number: 0 },
        // ロケーション区分.あり
        locationKbn_ari: { number: 1 },

        // 【自動調整理由区分】良品→保留
        kbn_zaiko_chosei_ryohin: { text: "sys9000001" },
        // 【自動調整理由区分】保留→良品
        kbn_zaiko_chosei_horyu: { text: "sys9000002" },
        // 【自動調整理由区分】返品
        kbn_zaiko_chosei_henpin: { text: "161" },
        // 【調整理由区分】返品取消
        kbn_zaiko_chosei_henpintorikeshi: { text: "162" },

        // 【機能区分】納入単位(端数)区分
        kinoTaniHasuKbn: { number: 6 },
        // 納入単位(端数)区分.使用しない
        kbnTaniHasuMishiyo: { number: 0 },
        // 納入単位(端数)区分.使用する
        kbnTaniHasuShiyo: { number: 1 },

        // 【機能区分】賞味期限区分
        kinoShomikigenKbn: { number: 7 },
        // 賞味期限区分.必須にしない
        kinoShomikigenNotRequired: { number: 0 },
        // 賞味期限区分.必須にする
        kinoShomikigenRequired: { number: 1 },

        // 【機能区分】納入実績区分
        kinoNonyuJisekiKbn: { number: 8 },
        // 納入実績区分.入力不可
        kinoNonyuJisekiNyuryokuFuka: { number: 0 },
        // 納入実績区分.入力可
        kinoNonyuJisekiNyuryokuKa: { number: 1 },

        // 【機能区分】荷受納入日区分(荷受で使用)
        kinoNiukeNonyubiKbn: { number: 9 },
        // 荷受納入日区分.使用しない
        kinoNiukeNonyubiMishiyo: { number: 0 },
        // 荷受納入日区分.使用する
        kinoNiukeNonyubiShiyo: { number: 1 },

        // 【機能区分】在庫区分変更調整数反映(荷受で使用)
        kinoChoseiKbn: { number: 10 },
        // 在庫区分変更調整数反映.しない
        choseiNashi: { number: 0 },
        // 在庫区分変更調整数反映.する
        choseiAri: { number: 1 },

        // 【機能区分】確定フラグ自動区分(荷受で使用)
        kinoKakuteiJidoKbn: { number: 11 },
        // 確定フラグ自動区分.する
        kinoKakuteiJidoSuru: { number: 0 },
        // 確定フラグ自動区分.しない
        kinoKakuteiJidoShinai: { number: 1 },

        // 【機能区分】原価発生部署使用区分
        kinoGenkaHaseiBUshoShiyoKbn: { number: 12 },
        // 原価発生部署使用区分.しない
        kinoGenkaHaseiBUshoShiyoShinai: { number: 0 },
        // 原価発生部署使用区分.する
        kinoGenkaHaseiBUshoShiyoSuru: { number: 1 },

        // 【機能区分】倉庫使用区分
        kinoSokoShiyoKbn: { number: 13 },
        // 倉庫使用区分.しない
        kinoSokoShiyoShinai: { number: 0 },
        // 倉庫使用区分.する
        kinoSokoShiyoSuru: { number: 1 },

        // 【機能区分】品名表示切替区分
        kinoHinmeiHyojiKbn: { number: 14 },
        //【品名表示切替区分】全て表示
        kbn_hinmei_kirikae_all: { number: 0 },
        //【品名表示切替区分】日本語
        kbn_hinmei_kirikae_ja: { number: 1 },
        //【品名表示切替区分】英語
        kbn_hinmei_kirikae_en: { number: 2 },
        //【品名表示切替区分】中国語
        kbn_hinmei_kirikae_zh: { number: 3 },
        //【品名表示切替区分】
        kbn_hinmei_kirikae_vi: { number: 4 },

        // 【機能区分】伝送表示切替区分
        kinoDensoHyojiKbn: { number: 15 },
        // 伝送表示切替区分.非表示
        kbnDensoHihyoji: { number: 0 },
        // 伝送表示切替区分.表示
        kbnDensoHyoji: { number: 1 },

        // 【機能区分】入庫区分入力区分
        kinoNyukoNyuryokuKubun: { number: 16 },
        // 入庫区分入力区分.なし
        kinoNyukoKubunNyuryokuNashi: { number: 0 },
        // 入庫区分入力区分.あり
        kinoNyukoKubunNyuryokuAri: { number: 1 },

        // 【機能区分】製造日報賞味期限自動計算
        kinoSeizoNippoShomiKigenAutoCalc: { number: 19 },
        // 製造日報賞味期限自動計算.しない
        kinoSeizoNippoShomiKigenAutoCalcShinai: { number: 0 },
        // 製造日報賞味期限自動計算.する
        kinoSeizoNippoShomiKigenAutoCalcSuru: { number: 1 },

        // 【機能区分】必須チェック切替区分
        kinoRequiredKbn: { number: 20 },
        // 必須チェック切替区分.任意
        kinoNotRequired: { number: 0 },
        // 必須チェック切替区分.必須
        kinoRequired: { number: 1 },

        // 【機能区分.枠線表示切替区分】
        kinoWakusenHyojiKbn: { number: 21 },
        // 枠線表示切替区分.表示しない
        kbnWakusenNashi:{ number: 0 },
        // 枠線表示切替区分.表示する
        kbnWakusenAri:{ number: 1 },

        // 【機能区分.PLC表示切替区分】
        kinoPlcHyojiKbn: { number: 24 },
        // 枠線表示切替区分.表示しない
        kbnPlcNashi: { number: 0 },
        // 枠線表示切替区分.表示する
        kbnPlcAri: { number: 1 },

        // 【機能区分.在庫伝送ボタン表示区分】
        kinoZaikoDensoButtonHyojiKbn: { number: 25 },
        // 在庫伝送ボタン表示切替区分.表示しない
        kbnZaikoDensoButtonNashi:{ number: 0 },
        // 在庫伝送ボタン表示切替区分.表示する
        kbnZaikoDensoButtonAri:{ number: 1 },

        // 【機能区分.検索日程表示区分】 20170906 echigo add start 【北京杭州】変動表の日程の検索条件の変更
        kinoKensakuDateHyojiKbn: { number: 28 },
        // 検索日程表示区分.表示しない
        kbnKensakuDateNashi: { number: 0 },
        // 検索日程表示区分.表示する
        kbnKensakuDateAri: { number: 1 },   //20170906 echigo add end

        // 【機能区分：庫出依頼職場表示切替区分】
        Kbnshokuba: { number: 29 },
        // 庫出依頼職場表示切替区分：表示しない
        KbnshokubaNashi:{ number: 0 },
        // 庫出依頼職場表示切替区分：表示する
        KbnshokubaAri: { number: 1 },

        //////////【機能区分】ここまで

        //////////【採番区分】
        // 製品ロット
        seihinLotSaibanKbn: { text: "1" },
        seihinLotPrefixSaibanKbn: { text: "P" },

        // 仕掛品ロット
        shikakariLotSaibanKbn: { text: "2" },
        shikakariLotPrefixSaibanKbn: { text: "S" },
        //////////【採番区分】ここまで

        // TODO:システムで利用する固定値を記入します
        // 【値】０
        systemValueZero: { text: "0" },
        // 【値】１
        systemValueOne: { text: "1" },
        // 【値】２
        systemValueTwo: { text: "2" },
        // 【値】100
        systemValueHundred: { text: "100", number: 100 },
        // 【値】1000
        systemValueThousand: { text: "1000", number: 1000 },
        // 【値】g
        gramText: { text: "g" },
        // 【初期値】版番号
        hanNoShokichi: { text: "1" },
        // 【初期値】工程番号
        koteiNoShokichi: { text: "1" },
        // 【初期値】 日付
        dateShokichi: { text: "01/01/1975" },
        // 【初期値】 ライン登録
        //lineTorokuShokichi: { text: "なし" },
        lineTorokuShokichi: { text: "Không có" },
        // 【初期値】 合算フラグ
        gassanFlgShokichi: { text: "1" },
        // 【初期値】 歩留
        budomariShokichi: { text: "100.00" },
        // 【初期値】 重量
        juryoShokichi: { text: "100" },
        // 【初期値】 基本倍率
        ritsuKihonShokichi: { text: "1.00" },
        // 【初期値】 比重
        hijuShokichi: { text: "1.0000" },
        // 【初期値】 初期化
        shokikaShokichi: { text: "" },
        // 【初期値】　展開フラグ
        tenkaiFlgShokichi: { text: "1" },

        // 【判定値】 自家原料
        jikagenTextValue: { text: "jikagen" },

        // 【最大値】 版番号
        maxHanNo: { text: "99" },

        // 【一般定数】年間月数
        monthCount: { text: 12 },

        // 【最小値】 日付
        minDate: { text: "1970/01/01" },
        // 【最大値】 日付
        maxDate: { text: "3000/12/31" },

        // 【excel出力ヘッダ】検索未設定
        noSelectConditionExcel: { text: "Chưa chọn" },
        // 【excel出力ヘッダ】チェックボックスon
        onCheckBoxExcel: { text: "Chọn" },

        // 【定数定義】未
        yet: { text: "Chưa xuất kho" },
        // 【定数定義】済
        arranged: { text: "Đã xuất kho" },

        // コードデータの先頭三文字
        preLetters: { text: "[)>" },

        // AI
        ai_free_text: { text: "07" },       // フリーテキストデータ
        ai_cd_hinmei: { text: "01" },       // 品名コード
        ai_dt_kigen: { text: "17" },        // 賞味期限
        ai_dt_seizo: { text: "11" },        // 製造日
        ai_no_lot: { text: "10" },          // ロットNo.
        ai_serial_number: { text: "21" },   // シリアルNo.(ラベル発行日時)
        ai_cd_hin: { text: "91" },          // 品コード
        ai_nm_hinmei: { text: "A1" },       // 品名
        ai_nm_maker_kojo: { text: "A2" },   // メーカー工場名
        ai_dt_kigen_shiyo: { text: "A4" },   // 使用期限日
        ai_wt_jyuryo_k: { text: "A6" },   // 重量(K)
        ai_wt_jyuryo_g: { text: "A7" },   // 重量(g)
        ai_label_kbn: { text: "A8" },       // ラベル区分
        ai_fixed_text: { text: "05" },      // 固定データ

        // 制御ｼﾝﾎﾞﾙコード
        symbol_EOT: { text: '%04' },
        symbol_GS: { text: '%1D' },
        symbol_RS: { text: '%1E' },

        // 【権限】管理者
        admin: { text: "Admin" },
        // 【権限】作業者
        editor: { text: "Editor" },
        // 【権限】入力作業者
        operator: { text: "Operator" },
        // 【権限】参照
        viewer: { text: "Viewer" },
        // 【権限】製造者
        manufacture: { text: "Manufacture" },
        // 【権限】購買担当者
        purchase: { text: "Purchase" },
        // 【権限】品管担当者
        quality: { text: "Quality" },
        // 【権限】荷受担当者
        warehouse: { text: "Warehouse" },

        // 【チェックボックス】ＯＮ 
        checkBoxCheckOn: { text: "1" },
        // 【チェックボックス】 ＯＦＦ
        checkBoxCheckOff: { text: "0" },

        // 休日解除コード
        kyujitsuKaijyo: { text: "*" },

        // 【検索上限件数】
        topCount: { text: 100 },
        topCount500: { text: 500 },
        // 【ラベルフォーマット】
        labelFormatKowake: { text: 1001 },
        // ラベル区分
        jikagenLabelKbn: { text: 3 },

        // 【日付フォーマット】　米国
        yearStartPosUS: { number: 6 },
        monthStartPosUS: { number: 0 },
        dayStartPosUS: { number: 3 },

        // 【日付フォーマット】　米国以外
        yearStartPos: { number: 6 },
        yearBeforePos: { number: 5 },
        monthStartPos: { number: 3 },
        dayStartPos: { number: 0 },

        // TODO:ここまで

        //小分ラベル 単位　：　LB
        tani_LB_text: { text: "LB" },
        //小分ラベル 単位　：　Kg
        tani_Kg_text: { text: "Kg" },

        // 単位：L
        tani_L_text: { text: "L" },
        // 単位：GAL
        tani_Gal_text: { text: "GAL" },

        // 原価発生部署デフォルトコード
        genkaHaseiBushoDefaultCode: { text: "21000" },

        //---------------------------------------------------------
        //2019/07/23 trinh.bd Update new column from [vw_user_info]
        //------------------------START----------------------------
        //Roles hidden.
        isRoleHinmei: { number: 0 },
        isRoleHaigo: { number: 0 },
        isRoleKonyusaki: { number: 0 },
        isRoleShikomiChohyo: { number: 0 },
        //Roles show.
        isRoleFisrt: { number: 1 },
        isRoleSecond: { number: 2 },
        //-------------------------END-----------------------------
        // TODO:cookieチェック処理で使用する値を設定します
        // チェックするcookieの値
        checkCookie: { text: "complete" },
        // チェックするcookieの値
        delCookie: { text: "=; expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/" },

        // 各画面ごとのcookieの名称
        // 月間製品計画
        gekkanSeihinKeikakuCookie: { text: "gekkanSeihinKeikaku" },
        //　製造日報
        SeizoNippoCookie: { text: "SeizoNippo" },
        //　原資材変動表
        GenshizaiHendoHyoCookie: { text: "GenshizaiHendoHyo" },
        //　月間仕掛計画
        gekkanShikakarihinKeikakuCookie: { text: "gekkanShikakarihinKeikaku" },
        //　警告リスト作成
        keikokuListSakuseiCookie: { text: "keikokuListSakusei" },
        //　変動表シミュレーション
        hendoHyoSimulationCookie: { text: "hendoHyoSimulation" },
        //　仕掛品使用一覧
        genshizaiShikakarihinShiyoIchiranCookie: { text: "genshizaiShikakarihinShiyoIchiran" },
        //　原資材受払一覧
        genshizaiUkeharaiIchiranCookie: { text: "genshizaiUkeharaiIchiran" },
        //　仕込み日報
        shikomiNippoCookie: { text: "shikomiNippo" },
        //　原価一覧
        genkaIchiranCookie: { text: "genkaIchiran" },
        //　品名マスタ
        hinmeiMasterCookie: { text: "hinmeiMaster" },
        //　配合マスタ一覧
        haigoMasterIchiranCookie: { text: "haigoMasterIchiran" },
        //　取引先マスタ
        torihikisakiMasterCookie: { text: "torihikisakiMaster" },
        //　原料注意喚起マスタ
        genryoChuikankiMasterCookie: { text: "genryoChuikankiMaster" },
        //　納入予定リスト
        nonyuYoteiListSakuseiCookie: { text: "nonyuYoteiListSakusei" },
        //　原資材調整入力
        genshizaiChoseiNyuryokuCookie: { text: "genshizaiChoseiNyuryoku" },
        //　原資材在庫入力
        genshizaiZaikoNyuryokuCookie: { text: "genshizaiZaikoNyuryoku" },
        //　原資材購入先マスタ
        genshizaiKonyusakiMasterCookie: { text: "genshizaiKonyusakiMaster" },
        //　庫出依頼
        genryoShiyoKeisanCookie: { text: "genryoShiyoKeisan" },
        //　印刷選択ダイアログ（仕掛品仕込計画）
        insatsuSentakuDialogCookie: { text: "insatsuSentakuDialog" },
        //　EXCEL(期間選択)ダイアログ（原資材調整入力）
        genshizaichoseinyuryokuExcelIkatsuDialogCookie: { text: "genshizaichoseinyuryokuExcelIkatsuDialog" },
        //　職場選択ダイアログ
        shokubaDialogCookie: { text: "shokubaDialog" },
        // TODO:ここまで
        HistoryChangeMasterCookie: { text: "HistoryChangeMaster" },

        //kbn_data_rireki
        ProductionPlan: {
            number: 0,
            text: "Kế hoạch sản xuất"
        },
        adjusted: {
            number: 1,
            text: "Điều chỉnh"
        },

        //kbn_shori_rireki
        New: {
            number: 0,
            text: "Thêm mới"
        },
        Change: {
            number: 1,
            text: "Thay đổi"
        },
        Delete: {
            number: 2,
            text: "Xóa"
        }
    });

})()