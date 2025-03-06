(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "User Id" },
        // 明細
        cd_tanto: { text: "Code" },
        nm_tanto: { text: "Name" },
        RoleName: { text: "Authority" },
        mishiyoFlag: { text: "Unused" },
        blank: { text: "" },
        // 検索条件
        tantoshaNameSearchText: { text: "Name" },
        roleNameSearch: { text: "Authority" },
        searchConfirm: { text: MS0065 },
        // リテラル
        password: { text: "Password" },
        passwordConfirm: { text: "For check password" },
        //passwordReset: { text: "Clear passwor" },
        passwordReset: { text: "Clear password" },
        kyoseiHoshinFlag: { text: "Force stepping" },

        adminText: { text: "Administrator" },
        editorText: { text: "Operator name" },
        operatorText: { text: "Input operator" },
        manufactureText: { text: "Manufacture" },
        purchaseText: { text: "Purchase" },
        qualityText: { text: "Quality" },
        warehouseText: { text: "Warehouse" },
        viewerText: { text: "Viewer" },
        inputAnnounceText: { text: "Input at least five characters in password." },
        inputAnnounce2Text: { text: "When you select blank in the Individual Setting,it is not displayed on the screen." },
        //---------------------------------------------------------
        //2019/07/23 trinh.bd Task #14029 No.3
        //------------------------START----------------------------
        kobetsuSetteiText: { text: "Individual Setting" },
        hinMeiText: { text: "Material Master" },
        haigoText: { text: "Formula Master" },
        konyuText: { text: "Source List" },
        shikakarihinText: { text: "Mixer Plan" },
        insatsuKinoText: { text: "Print function" },
        //-------------------------END-----------------------------

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

    App.ui.pagedata.validation("en", {
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
                required: "Person in charge code",
                alphanum: true,
                maxbytelength: 10
                
                
            },
            params: {
                custom: "Person in charge code"
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
                required: "Name of person in charge",
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
                required: "Password",
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
                required: "Password",
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
    App.ui.pagedata.operation("en", {
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
