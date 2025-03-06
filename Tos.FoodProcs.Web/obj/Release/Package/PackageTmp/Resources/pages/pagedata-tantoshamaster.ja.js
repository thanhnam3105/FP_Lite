(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "担当者マスタ" },
        // 明細
        cd_tanto: { text: "コード" },
        nm_tanto: { text: "担当者名" },
        RoleName: { text: "権限" },
        mishiyoFlag: { text: "未使用" },
        blank: { text: "" },
        // 検索条件
        tantoshaNameSearchText: { text: "担当者" },
        roleNameSearch: { text: "権限" },
        searchConfirm: { text: MS0065 },
        // リテラル
        password: { text: "パスワード" },
        passwordConfirm: { text: "パスワード確認用" },
        passwordReset: { text: "パスワードクリア" },
        kyoseiHoshinFlag: { text: "強制歩進" },


        //旧権限
        editorText: { text: "製造作業者" },
        operatorText: { text: "入力作業者" },
        viewerText: { text: "閲覧者" },
        //新権限
        adminText: { text: "管理者" },
        manufactureText: { text: "製造者" },
        purchaseText: { text: "購買担当者" },
        qualityText: { text: "品管担当者" },
        warehouseText: { text: "荷受担当者" },

        //---------------------------------------------------------
        //2019/07/23 trinh.bd Task #14029 No.3
        //------------------------START----------------------------
        kobetsuSetteiText: { text: "個別設定" },
        hinMeiText: { text: "品名マスタ" },
        haigoText: { text: "配合名マスタ" },
        konyuText: { text: "購入先マスタ" },
        shikakarihinText: { text: "仕掛品仕込計画" },
        insatsuKinoText: { text: "印刷機能" },
        //-------------------------END-----------------------------

        inputAnnounceText: { text: "パスワードは、半角５文字以上で入力してください" },
        inputAnnounce2Text: { text: "個別設定で空白を選択した場合、画面の非表示を表します" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        deleteConfirm: { text: MS0068 },
        showGridConfirm: { text: MS0072 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: {text: MS0560},
        diffCode: {text: MS0709},
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        tantoshaNameSearchText: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        cd_tanto: {
            rules: {
                required: "担当者コード",
                alphanum: true,
                maxbytelength: 10
                
                
            },
            params: {
                custom: "担当者コード"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0045
            }
        },
        nm_tanto: {
            rules: {
                required: "担当者名",
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        password: {
            rules: {
                required: "パスワード",
                maxbytelength: 128,
                minbytelength: 5,
                passwordilligalchar: true
            },
            messages: {
                required: MS0042,
                minbytelength: MS0571,
                maxbytelength: MS0012,
                passwordilligalchar: MS0005,
                custom: MS0574
            }
        },
        passwordConfirm: {
            rules: {
                required: "パスワード",
                maxbytelength: 128,
                minbytelength: 5,
                passwordilligalchar: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                minbytelength: MS0571,
                passwordilligalchar: MS0005,
                custom: MS0574
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            //Operator: { visible: false },
            //Editor: { visible: false },
            //Viewer: { visible: false }
        },
        colchange: {
            //Operator: { visible: false },
            //Editor: { visible: false },
            //Viewer: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },        
        detail: {
            //Operator: { visible: false },
            //Editor: { visible: false },
            //Viewer: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }

        // TODO: ここまで
    });

    //// ページデータ -- End
})();
