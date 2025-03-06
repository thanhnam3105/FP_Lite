(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master nhân viên" },
        // 明細
        cd_tanto: { text: "Mã" },
        nm_tanto: { text: "Tên nhân viên" },
        RoleName: { text: "Quyền" },
        mishiyoFlag: { text: "Không<br>sử dụng" },
        blank: { text: "" },
        // 検索条件
        tantoshaNameSearchText: { text: "Nhân viên" },
        roleNameSearch: { text: "Quyền" },
        searchConfirm: { text: MS0065 },
        // リテラル
        password: { text: "Mật khẩu" },
        passwordConfirm: { text: "Mật khẩu xác nhận" },
        //passwordReset: { text: "Clear passwor" },
        passwordReset: { text: "Xóa mật khẩu" },
        kyoseiHoshinFlag: { text: "BỎ QUA (hệ thống đổ trộn)" },

        adminText: { text: "Quản lý" },
        editorText: { text: "Nhập liệu" },
        operatorText: { text: "Vận hành" },
        manufactureText: { text: "Bộ phận sản xuất" },
        purchaseText: { text: "Bộ phận thu mua" },
        qualityText: { text: "Bộ phận quản lý chất lượng" },
        warehouseText: { text: "Bộ phận kho" },
        viewerText: { text: "Xem" },
        inputAnnounceText: { text: "Hãy nhập tối thiểu 5 ký tự không dấu đối với mật khẩu." },
        inputAnnounce2Text: { text: "Nếu bạn không chọn quyền ở mục Thiết lập khác, màn hình tương ứng sẽ bị ẩn trên Menu." },
        //---------------------------------------------------------
        //2019/07/23 trinh.bd Task #14029 No.3
        //------------------------START----------------------------
        kobetsuSetteiText: { text: "Thiết lập khác" },
        hinMeiText: { text: "Master nguyên vật liệu" },
        haigoText: { text: "Master công thức" },
        konyuText: { text: "Master nhà cung cấp" },
        shikakarihinText: { text: "Kế hoạch sản xuất BTP" },
        insatsuKinoText: { text: "Chức năng in" },
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

    App.ui.pagedata.validation("vi", {
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
                required: "Mã nhân viên",
                alphanum: true,
                maxbytelength: 10
                
                
            },
            params: {
                custom: "Mã nhân viên"
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
                required: "Tên nhân viên",
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
                required: "Mật khẩu",
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
                required: "Mật khẩu",
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
    App.ui.pagedata.operation("vi", {
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