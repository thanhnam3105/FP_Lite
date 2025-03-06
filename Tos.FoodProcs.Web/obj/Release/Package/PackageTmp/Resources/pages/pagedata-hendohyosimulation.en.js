
(function () {
    // 定数設定
    var lang = App.ui.pagedata.lang("en", {
        // 画面タイトル
        _pageTitle: { text: "Material Inventory Simulation" },
        // 項目名・検索条件
        con_dt_hizuke: { text: "Date" },
        con_cd_hinmei: { text: "Code" },
        con_nm_hinmei: { text: "Name" },
        con_seizo_yotei: { text: "Manufacture plan" },
        con_str_case: { text: "C/S" },
        con_str_arrow: { text: "->" },
        con_after_change: { text: "After change" },
        // 原資材情報
        genshi_cd_konyu: { text: "Vendor code" },
        genshi_nm_konyu: { text: "Vendor name" },
        genshi_leadtime: { text: "Delivery lead time" },
        genshi_zaiko_min: { text: "Minimum inventory" },
        genshi_hachu_lot_size: { text: "Order lot size" },
        genshi_tani_shiyo: { text: "Usage unit" },
        // 明細項目名(シミュレーションスプレッド項目名)
        dt_hizuke: { text: "Date" },
        after_su_nonyu: { text: "Delivery<br>quantity" },
        su_seizo: { text: "Manufacture<br>quantity" },
        before_wt_shiyo: { text: "Usage quantity<br>before change" },
        after_wt_shiyo: { text: "Usage quantity<br>after change" },
        before_wt_zaiko: { text: "Inventory quantity<br>before change" },
        after_wt_zaiko: { text: "Inventory quantity<br>after change" },
        su_zaiko: { text: "Actual inventory<br>quantity" },
        // 明細原料項目名(原料スプレッド項目名)
        cd_genryo: { text: "Code" },
        nm_genryo: { text: "Name" },
        genryo_wt_shiyo: { text: "Usage quantity" },
        genryo_wt_zaiko: { text: "Inventory quantity" },
        // 明細資材項目名(資材スプレッド項目名)
        cd_shizai: { text: "Code" },
        nm_shizai: { text: "Packing materials name" },
        shizai_wt_shiyo: { text: "Usage quantity" },
        shizai_wt_zaiko: { text: "Inventory quantity" },
        // 項目名・隠し項目
        dt_ymd: { text: "date/month/year" },
        flg_kyujitsu: { text: "Holiday flag" },
        save_before_su_nonyu: { text: "Delivery amount before change at search time" },
        before_su_nonyu: { text: "Delivery amount before change" },
        flg_mishiyo: { text: "Unused flag" },
        genryo_bef_wt_shiyo: { text: "Usage amount before change" },
        genryo_bef_wt_zaiko: { text: "Inventory amount before change" },
        su_shiyo: { text: "Usage amount" },
        ritsu_budomari: { text: "Yield" },
        shizai_bef_wt_shiyo: { text: "Usage amount before change" },
        shizai_bef_wt_zaiko: { text: "Inventory amount before change" },
        dd_leadtime: { text: "Delivery lead time" },
        su_zaiko_min: { text: "Minimum inventory" },
        su_hachu_lot_size: { text: "Order lot size" },
        cd_tani_shiyo: { text: "Usage unit code" },
        cd_tani_nonyu: { text: "Delivery unit code" },
        kbn_hin: { text: "Item type" },
        tan_nonyu: { text: "Delivery unit price" },
        kbn_zei: { text: "Tax type" },
        su_ko: { text: "Quantity of one product(kg)" },
        su_iri: { text: "Contained number" },
        cd_tani:{ text: "Unit code"},
        konyusaki: { text: "Vendor" },
        konyusakiMaster: { text: "Source List" },
        // EXCEL出力用文言
        str_genryo: { text: "Raw materials" },
        str_shizai: { text: "Packing materials" },
        //str_code: { text: "Code　　　 ：" },
        //str_name: { text: "Name　　　 ：" },
        str_code: { text: "Code       ：" },
        str_name: { text: "Name       ：" },
        su_seizo_excel: { text: "Manufacture quantity" },
        param_su_nonyu: { text: "Delivery quantity" },
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
        dt_hizuke_width: { number: 50 },
        after_su_nonyu_width: { number: 104 },
        before_wt_shiyo_width: { number: 120 },
        after_wt_shiyo_width: { number: 120 },
        before_wt_zaiko_width: { number: 120 },
        after_wt_zaiko_width: { number: 120 },
        su_zaiko_width: { number: 130 },
        recipeHinmeiCode_width: { number: 112 },
        recipeHinmeiName_width: { number: 234 },
        genryo_wt_shiyo_width: { number: 130 },
        genryo_wt_zaiko_width: { number: 130 },
        cd_shizai_width: { number: 112 },
        nm_shizai_width: { number: 234 },
        shizai_wt_shiyo_width: { number: 130 },
        shizai_wt_zaiko_width: { number: 130 },
        each_lang_width: { number: 120 }
        // TODO: ここまで
    });

    // バリデーション設定
    App.ui.pagedata.validation("en", {
        // 検索条件/日付
        con_dt_hizuke: {
            rules: {
                required: "Date",
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
                required: "Item name code",
                alphanum: true
            },
            params: {
                custom: "Item name code"
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
    App.ui.pagedata.operation("en", {
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
