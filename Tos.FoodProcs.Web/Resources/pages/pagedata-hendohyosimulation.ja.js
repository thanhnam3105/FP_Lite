
(function () {
    // 定数設定
    var lang = App.ui.pagedata.lang("ja", {
        // 画面タイトル
        _pageTitle: { text: "変動表シミュレーション" },
        // 項目名・検索条件
        con_dt_hizuke: { text: "日付" },
        con_cd_hinmei: { text: "品名コード" },
        con_nm_hinmei: { text: "品名" },
        con_seizo_yotei: { text: "製造予定" },
        con_str_case: { text: "C/S" },
        con_str_arrow: { text: "→" },
        con_after_change: { text: "変更後" },
        // 原資材情報
        genshi_cd_konyu: { text: "購入先コード" },
        genshi_nm_konyu: { text: "購入先名" },
        genshi_leadtime: { text: "納入リードタイム" },
        genshi_zaiko_min: { text: "最低在庫" },
        genshi_hachu_lot_size: { text: "発注ロットサイズ" },
        genshi_tani_shiyo: { text: "使用単位" },
        // 明細項目名(シミュレーションスプレッド項目名)
        dt_hizuke: { text: "日" },
        after_su_nonyu: { text: "納入数" },
        su_seizo: { text: "製造数" },
        before_wt_shiyo: { text: "変更前使用量" },
        after_wt_shiyo: { text: "変更後使用量" },
        before_wt_zaiko: { text: "変更前在庫量" },
        after_wt_zaiko: { text: "変更後在庫量" },
        su_zaiko: { text: "実在庫数" },
        // 明細原料項目名(原料スプレッド項目名)
        cd_genryo: { text: "コード" },
        nm_genryo: { text: "原料名" },
        genryo_wt_shiyo: { text: "使用量" },
        genryo_wt_zaiko: { text: "在庫量" },
        // 明細資材項目名(資材スプレッド項目名)
        cd_shizai: { text: "コード" },
        nm_shizai: { text: "資材名" },
        shizai_wt_shiyo: { text: "使用量" },
        shizai_wt_zaiko: { text: "在庫量" },
        // 項目名・隠し項目
        dt_ymd: { text: "年月日" },
        flg_kyujitsu: { text: "休日フラグ" },
        save_before_su_nonyu: { text: "検索時変更前納入数" },
        before_su_nonyu: { text: "変更前納入数" },
        flg_mishiyo: { text: "未使用フラグ" },
        genryo_bef_wt_shiyo: { text: "変更前使用量" },
        genryo_bef_wt_zaiko: { text: "変更前在庫量" },
        su_shiyo: { text: "使用数" },
        ritsu_budomari: { text: "歩留" },
        shizai_bef_wt_shiyo: { text: "変更前使用量" },
        shizai_bef_wt_zaiko: { text: "変更前在庫量" },
        dd_leadtime: { text: "納入リードタイム" },
        su_zaiko_min: { text: "最低在庫" },
        su_hachu_lot_size: { text: "発注ロットサイズ" },
        cd_tani_shiyo: { text: "使用単位コード" },
        cd_tani_nonyu: { text: "納入単位コード" },
        kbn_hin: { text: "品区分" },
        tan_nonyu: { text: "納入単価" },
        kbn_zei: { text: "税区分" },
        su_ko: { text: "個数" },
        su_iri: { text: "入数" },
        cd_tani: { text: "納入単位" },
        konyusaki: { text: "購入先" },
        konyusakiMaster: { text: "原資材購入先マスタ" },
        param_su_nonyu: { text: "納入数" },
        // EXCEL出力用文言
        str_genryo: { text: "原料" },
        str_shizai: { text: "資材" },
        str_code: { text: "コード　　　　：" },
        str_name: { text: "名　　　　　　：" },
        su_seizo_excel: { text: "製造数" },
        // 画面メッセージＩＤ
        notFound: { text: MS0037 },
        changeCriteria: { text: MS0048 },
        saveConfirm: { text: MS0064 },
        keikakuConfirm: { text: MS0689 },
        searchConfirm: { text: MS0065 },
        unloadWithoutSave: { text: MS0066 },
        noRecords: { text: MS0442 },
        noChange: { text: MS0444 },
        gridChange: { text: MS0560 },
        line_shokuba_codeNotFound: { text: MS0122 },
        zaikoNotFound: { text: MS0615 },
        finishCalc: { text: MS0041 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        dt_hizuke_width: { number: 45 },
        after_su_nonyu_width: { number: 104 },
        before_wt_shiyo_width: { number: 104 },
        after_wt_shiyo_width: { number: 104 },
        before_wt_zaiko_width: { number: 104 },
        after_wt_zaiko_width: { number: 104 },
        su_zaiko_width: { number: 130 },
        recipeHinmeiCode_width: { number: 112 },
        recipeHinmeiName_width: { number: 222 },
        genryo_wt_shiyo_width: { number: 104 },
        genryo_wt_zaiko_width: { number: 104 },
        cd_shizai_width: { number: 112 },
        nm_shizai_width: { number: 222 },
        shizai_wt_shiyo_width: { number: 104 },
        shizai_wt_zaiko_width: { number: 104 },
        each_lang_width: { number: 110 }
        // TODO: ここまで
    });

    // バリデーション設定
    App.ui.pagedata.validation("ja", {
        // 検索条件/日付
        con_dt_hizuke: {
            rules: {
                required: "日付",
                datestring: true,
                lessdate: new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0127,
                greaterdate: MS0247
            }
        },
        // 検索条件/品名コード
        con_cd_hinmei: {
            rules: {
                required: "品名コード",
                alphanum: true
            },
            params: {
                custom: "品名コード"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        // 検索条件/変更後
        con_after_change: {
            rules: {
                number: true,
                range: [0, 99999],
                digits: [5]
            },
            messages: {
                number: MS0441,
                range: MS0450,
                digits: MS0576
            }
        },
        // 明細/(変更後)納入数
        after_su_nonyu: {
            rules: {
                number: true,
                //range: [0, 999999.99]
                range: [0, 999999.999]
            },
            messages: {
                number: MS0441,
                range: MS0450
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("ja", {
        // ボタン：計算
        calc: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：保存
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：計画作成
        planmake: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：検索条件/製品一覧
        seihinIchiran: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：EXCEL
        excel: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });
})();
