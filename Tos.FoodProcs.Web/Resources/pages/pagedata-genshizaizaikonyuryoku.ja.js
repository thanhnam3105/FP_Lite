(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原資材在庫入力" },
        // 検索条件
        dt_zaiko: { text: "在庫日付" },
        shiyoubun: { text: "使用分" },
        mishiyoubun: { text: "未使用分" },
        ari_nomi: { text: "計算在庫／実在庫ありのみ" },
        hinKubun: { text: "品区分" },
        hinBunrui: { text: "品分類" },
        kurabasho: { text: "庫場所" },
        hinmei: { text: "品名" },
        ryohin: { text: "良品" },
        horyu: { text: "保留品" },
        soko: { text: "倉庫" },
        // 明細
        flg_kakutei: { text: "確定" },
        cd_hinmei: { text: "コード" },
        nm_hinmei: { text: "原資材名" },
        nm_nisugata: { text: "荷姿" },
        tani_nonyu: { text: "納入<br>単位" },
        tani_shiyo: { text: "使用<br>単位" },
        keisan_zaiko: { text: "計算在庫数<br>(使用単位)" },
        jitsuzaiko_nonyu: { text: "実在庫数<br>(納入単位)" },
        jitsuzaiko_hasu: { text: "実在庫端数<br>(納入単位)" },
        su_zaiko: { text: "実在庫数<br>(使用単位)" },
        dt_kakutei_zaiko: { text: "実在庫数<br>確定日" },
        flg_mishiyo: { text: "未使用" },
        tan_tana: { text: "単価" },
        kingaku: { text: "金額" },
        totalKingaku: { text: "合計金額" },
        sokoName: { text: "倉庫名" },
        sokoCode: { text: "倉庫コード" },
        copyKeisanZaiko: { text: "計算在庫コピー" },
        zaikoCopy: { text: "在庫コピー" },
        //retrasmitInventory: { text: "在庫再伝送" },
        retrasmitInventory: { text: "在庫伝送" },
        // 隠し項目
        wt_ko: { text: "個重量" },
        su_iri: { text: "入数" },
        nm_hinkbn: { text: "品区分(隠)" },
        cd_tani_nonyu: { text: "納入単位コード" },
        cd_kura: { text: "庫場所コード" },
        nm_kura: { text: "庫場所名" },
        //BRC quang.l 2022/04/21 #1699 Start -->
        dt_update: { text: "更新日" },
        //BRC quang.l 2022/04/21 #1699 Start <--
        // TODO: 伝送処理の確認
        id_jobnet: { text: "GETSUMATSU_ZAIKO"},
        flg_shori: { text: "1"},
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        excelChangeMeisai: { text: MS0560 },
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        changeCondition: { text: MS0299 },
        limitOver: { text: MS0011 },
        checkboxCondition: { text: MS0177 },
        successExcel: { text: MS0111 },
        zaikocopyConfirm: { text: MS0764 },
        zaikocopyChangeMeisai: { text: MS0765 },
        //retrasmitInventoryConfirm: { text: MS0788 },
        trasmitInventoryConfirm: { text: MS0804 },
        noDataRetrasmit: { text: MS0787 },
        //retrasmittingCompletion: { text: MS0789 },
        trasmittingCompletion: { text: MS0805 },
        trasmittingError: { text: MS0749 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        nm_soko_width: { number: 100 },
        nm_bunrui_width: { number: 120 },
        cd_hinmei_width: { number: 80 },
        nm_hinmei_width: { number: 180 },
        nm_nisugata_hyoji_width: { number: 100 },
        tani_nonyu_width: { number: 50 },
        tani_shiyo_width: { number: 50 },
        su_keisan_zaiko_width: { number: 100 },
        jitsuzaiko_nonyu_width: { number: 100 },
        jitsuzaiko_hasu_width: { number: 100 },
        su_zaiko_width: { number: 125 },
        dt_jisseki_zaiko_width: { number: 90 },
        tan_ko_width: { number: 90 },
        kingaku_width: { number: 110 },
        flg_mishiyo_width: { number: 80 },
        each_lang_width: { number: 100 },
        ari_nomi_width: { number: 195 },

        // 在庫伝送用パラメータ
        kbnCreate: { number: 1 },
        kbnUpdate: { number: 2 },
        kbnDelete: { number: 3 },
        flg_true: { number: 1 },
        flg_false: { number: 0 },
        kbnGenryo: { number: 2 },
        kbnShizai: { number: 3 },
        kbnJikagen: { number: 7 },
        kbnZaiko: { number: 1 },

        // TODO: ここまで
    });
    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        jitsuzaiko_nonyu: {
            rules: {
                range: [0, 99999999.9]
            },
            messages: {
                //range: MS0009
                range: MS0450
            }
        },
        jitsuzaiko_hasu: {
            rules: {
                range: [0, 99999999.9]
            },
            messages: {
                //range: MS0009
                range: MS0450
            }
        },
        su_zaiko: {
            rules: {
                //range: [0, 99999999.999999]
                range: [0, 99999999.999]
            },
            messages: {
                //range: MS0009
                range: MS0450
            }
        },
        //BRC t.Sato 2021/03/10 Start -->
        tan_tana: {
            rules: {
                range: [0, 99999999]
            },
            messages: {
                range: MS0450
            }
        },
        //BRC t.Sato 2021/03/10 End <--
        // 検索条件
        dt_zaiko: {
            rules: {
                required: "在庫日付",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        hinmei: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        colchange: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        save: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        excel: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        csvUpload: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        zaikoCopy: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        retrasmitInventory: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
