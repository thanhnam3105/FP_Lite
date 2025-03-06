(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "取引先マスタ一覧" },

        kbn_torihiki: { text: "取引先区分" },
        nm_kbn_torihiki: { text: "取引先区分" },
        nm_torihiki: { text: "取引先名称" },
        cd_torihiki: { text: "取引先コード" },
        nm_torihiki_ryaku: { text: "取引先名略" },
        nm_busho: { text: "部署名" },
        no_yubin: { text: "郵便番号" },
        nm_jusho: { text: "住所" },
        no_tel: { text: "ＴＥＬ" },
        no_fax: { text: "ＦＡＸ" },
        e_mail: { text: "Ｅ－Ｍａｉｌ" },
        nm_tanto_1: { text: "担当者（１）" },
        nm_tanto_2: { text: "担当者（２）" },
        nm_tanto_3: { text: "担当者（３）" },
        kbn_keishiki_nonyusho: { text: "納入書形式" },
        nm_kbn_keishiki_nonyusho: { text: "納入書形式" },
        kbn_keisho_nonyusho: { text: "敬称区分" },
        nm_kbn_keisho_nonyusho: { text: "敬称区分" },
        kbn_hin: { text: "品区分" },
        biko: { text: "備考" },
        cd_maker: { text: "メーカーコード" },
        flg_pikking: { text: "ピッキングフラグ" },
        flg_mishiyo: { text: "未使用" },
        display_unused: { text: "未使用表示" },
        dt_create: { text: "登録日" },
        cd_create: { text: "登録者コード" },
        dt_update: { text: "更新日" },
        cd_update: { text: "更新者コード" },
        ts: { text: "タイムスタンプ" },
        nonyusho: { text: "納入書形式" },
        notUse: { text: "使用しない場合" },
        nm_keishiki_nonyu: { text: "納入数量" },
        nm_keishiki_shiyou: { text: "使用数量" },
        nm_keisho_sama: { text: "様" },
        nm_keisho_onchu: { text: "御中" },
        nm_keisho_nashi: { text: "なし" },
        nm_flg_mishiyo_ari: { text: "あり" },
        nm_flg_mishiyo_nashi: { text: "なし" },
        deleteConfirm: { text: MS0068 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        clearConfirm: { text: MS0070 },
        unloadWithoutSave: { text: MS0066 },
        saveConfirm: { text: MS0064 },
        saveComplete: { text: MS0036 },
        deleteComplete: { text: MS0039 },
        changeCriteria: { text: MS0299 },
        // TODO: ここまで

        //要らないものをカットしていく 影居
        combDetail: { text: "配合詳細" },
        categoryCode: { text: "分類コード" },
        categoryName: { text: "分類名" },
        articleDivisionCD: { text: "仕掛品分類コード" },
        articleDivisionName: { text: "仕掛品分類名" },
        combinationCD: { text: "配合コード" },
        combinationName: { text: "配合名" },
        combinationShortName: { text: "配合名略" },
        combinationRomaName: { text: "配合名ローマ字" },
        yield: { text: "保留" },
        baseWeight: { text: "基本重量" },
        vwDivision: { text: "V/W区分" },
        specificGravity: { text: "比重" },
        facilitiesCD: { text: "設備コード" },
        facilitiesName: { text: "設備名" },
        maxWeight: { text: "仕込最大重" },
        lineCode: { text: "ラインコード" },
        lineName: { text: "ライン名" },
        priority: { text: "優先順" },
        combinationID: { text: "シーケンス番号" },
        other: { text: "他工場" },
        recipe: { text: "レシピ" },
        UpateTimestamp: { text: "更新日付" }
        // ここまで

    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_torihiki: {
            rules: {
                required: "取引先コード",
                alphanum: true,
                maxbytelength: 13
            },
            params: {
                custom: "取引先コード"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0045
            }
        },
        
        nm_torihiki: {
            rules: {
                required: "取引先名称",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        nm_busho: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_torihiki_ryaku: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_tanto_1: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_tanto_2: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_tanto_3: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        no_yubin: {
            rules: {
                haneisukigo: true,
                maxbytelength: 10
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_jusho: {
            rules: {
                maxbytelength: 100
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        no_tel: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_fax: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        cd_maker: {
            rules: {
                alphanum: true,
                maxbytelength: 13
            },
            messages: {
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        e_mail: {
            rules: {
                passwordilligalchar: true,
                maxbytelength: 256
            },
            messages: {
                passwordilligalchar: MS0005,
                maxbytelength: MS0012
            }
        },
        biko: {
            rules: {
                maxbytelength: 256
            },
            messages: {
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });
    App.ui.pagedata.validation2("ja", {
        //TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        con_nm_torihiki: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("ja", {
        search: {
            Manufacture: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        detail: {
            Manufacture: { visible: false }
        },
        copy: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Manufacture: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        clear: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

})();
