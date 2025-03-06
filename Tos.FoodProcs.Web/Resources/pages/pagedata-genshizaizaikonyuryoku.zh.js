(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原材料库存输入" },
        // 検索条件
        dt_zaiko: { text: "库存日期" },
        shiyoubun: { text: "使用部分" },
        mishiyoubun: { text: "未使用部分" },
        ari_nomi: { text: "计算库存/只是有实际库存" },
        hinKubun: { text: "商品区分" },
        hinBunrui: { text: "商品分类" },
        kurabasho: { text: "仓库地点" },
        hinmei: { text: "品名" },
        ryohin: { text: "合格品" },
        horyu: { text: "保留品" },
        soko: { text: "仓库" },
        // 明細
        flg_kakutei: { text: "确定" },
        cd_hinmei: { text: "编号" },
        nm_hinmei: { text: "原材料名" },
        //nm_nisugata: { text: "包装" },
        nm_nisugata: { text: "包装形式" },
        tani_nonyu: { text: "入库<br>单位" },
        tani_shiyo: { text: "使用<br>单位" },
        keisan_zaiko: { text: "计算库存数<br>(使用单位)" },
        jitsuzaiko_nonyu: { text: "实际库存数<br>(入库单位)" },
        //jitsuzaiko_hasu: { text: "实际库存零数<br>(入库单位)" },
        jitsuzaiko_hasu: { text: "实际库存零头数<br>(入库单位)" },
        su_zaiko: { text: "实际库存数<br>(使用单位)" },
        dt_kakutei_zaiko: { text: "实际库存数<br>确定日" },
        flg_mishiyo: { text: "未使用" },
        tan_tana: { text: "单价" },
        kingaku: { text: "金额" },
        totalKingaku: { text: "合计金额" },
        sokoName: { text: "仓库名" },
        sokoCode: { text: "仓库编号" },
        copyKeisanZaiko: { text: "计算库存复制" },
        zaikoCopy: { text: "库存复制" },
        //retrasmitInventory: { text: "库存再传送" },
        retrasmitInventory: { text: "库存传送" },
        // 隠し項目
        wt_ko: { text: "个重量" },
        su_iri: { text: "装箱数" },
        nm_hinkbn: { text: "商品区分(藏)" },
        cd_tani_nonyu: { text: "入库单位编号" },
        cd_kura: { text: "仓库地点编号" },
        nm_kura: { text: "仓库地点名" },
        //BRC quang.l 2022/04/21 #1699 Start -->
        dt_update: { text: "更新日" },
        //BRC quang.l 2022/04/21 #1699 Start <--
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
        // TODO: 伝送処理の確認
        id_jobnet: { text: "GETSUMATSU_ZAIKO"},
        flg_shori: { text: "1"},
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
    App.ui.pagedata.validation("zh", {
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
                required: "库存日期",
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
    App.ui.pagedata.operation("zh", {
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
