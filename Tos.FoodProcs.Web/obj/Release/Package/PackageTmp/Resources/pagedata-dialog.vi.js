(function () {

    App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        // ダイアログ名称
        torihikisakiDialog: { text: "Tìm kiếm master nhà cung cấp" },
        categoryDialog: { text: "Tìm kiếm mã phân loại" },
        haigoDialog: { text: "Tìm kiếm mã công thức" },
        hinmeiDialog: { text: "Tìm kiếm master sản phẩm" },
        finmeiDialog: { text: "Tìm kiếm master sản phẩm_" },
        lineDialog: { text: "Tìm kiếm master dây chuyền" },
        seizoLineDialog: { text: "Tìm kiếm master dây chuyền sản xuất" },
        kojoDialog: { text: "Tìm kiếm master nhà máy" },
        futaiDialog: { text: "Tìm kiếm master kiểu đóng gói" },
        futaiKetteiDialog: { text: "Tìm kiếm danh sách quy định kiểu đóng gói" },
        niukebashoDialog: { text: "Danh sách nơi nhận hàng" },
        commentDialog: { text: "Danh sách chú thích" },
        markDialog: { text: "Danh sách mác" },
        gokeiHyojiDialog: { text: "Hiển thị tổng theo từng sản phẩm" },
        yasumiItiranDialog: { text: "Danh sách lịch nghỉ" },
        labelinsatsuDialog: { text: "In nhãn" },
        gramTaniDialog: { text: "Nhập đơn vị G" },
        insatsuSentakuDialog: { text: "Tùy chọn in" },
        shiyoIchiranDialog: { text: "Danh sách nguyên vật liệu sử dụng" },
        genshizaiLotDialog: { text: "Nhập lô nguyên liệu" },
        ShikakariZanIchiranDialog: { text: "Tìm kiếm hàng tồn kho" },
        genryoLotSentakuDialog: { text: "Chọn lô nguyên liệu" },
        genryoLotTorikeshiDialog: { text: "Hủy bỏ lô" },
        JikaGenryoLotSentakuDialog: { text: "Chọn lô SP trung gian" },
        jikaGenryoLotTorikeshiDialog: { text: "Hủy lô SP trung gian" },
        shokubaSentakuDialog: { text: "Chọn bộ phận sản xuất" },
        excelikatsuDialog: { text: "EXCEL(chỉ định khoảng thời gian)" },
        between: { text: "　～　" },


        // 各ダイアログ内項目
        csvTitle: { text: "Tải CSV lên" },
        file1: { text: "Tập tin 1" },
        file2: { text: "Tập tin 2" },
        categoryCode: { text: "Mã phân loại" },
        categoryName: { text: "Tên phân loại" },
        torihikisakiCode: { text: "Mã nhà cung cấp" },
        torihikisakiName: { text: "Tên nhà cung cấp" },
        haigoCode: { text: "Mã công thức" },
        haigoName: { text: "Tên công thức" },
        cd_hinmei_dlg: { text: "Mã" },
        kbn_hin_dlg: { text: "Loại" },
        nm_hinmei_dlg: { text: "Tên" },
        nm_naiyo_dlg: { text: "Nội dung" },
        nm_haigo: { text: "Tên công thức" },
        cd_line_dlg: { text: "Mã" },
        nm_line_dlg: { text: "Tên" },
        cd_seihin_dlg: { text: "Mã" },
        nm_seihin_dlg: { text: "Tên sản phẩm" },
        nm_gokei_dlg: { text: "Số lượng tổng (C/S)" },
        cd_setsubi: { text: "Mã" },
        nm_setsubi: { text: "Tên" },
        cd_kojo: { text: "Mã" },
        nm_kojo: { text: "Tên" },
        cd_futai_dlg: { text: "Mã" },
        nm_futai_dlg: { text: "Tên" },
        cd_mark_dlg: { text: "Mã" },
        nm_mark_dlg: { text: "Tên" },
        cd_riyu_dlg: { text: "Mã lý do" },
        nm_riyu_dlg: { text: "Lý do" },
        mark_dlg: { text: "Mác" },
        startDate: { text: "Ngày bắt đầu" },
        endDate: { text: "Ngày kết thúc" },
        cd_niukebasho_dlg: { text: "Mã" },
        nm_niukebasho_dlg: { text: "Nơi nhận hàng" },
        cd_comment: { text: "Mã" },
        comment: { text: "Chú thích" },
        seq_comment_dlg: { text: "Số thứ tự" },
        genshizaikonyuDialog: { text: "Tìm kiếm master nhà cung cấp nguyên vật liệu" },
        con_cd_hinmei: { text: "Mã sản phẩm" },
        juni_yusen: { text: "Thứ tự<br>ưu tiên" },
        cd_torihiki_butsu: { text: "Mã<br>(logistic)" },
        nm_torihiki_butsu: { text: "Tên nhà cung cấp<br>(logistic)" },
        cd_torihiki_sho: { text: "Mã<br>(luồng giao dịch tiền)" },
        nm_torihiki_sho: { text: "Tên khách hàng<br>(luồng giao dịch tiền)" },
        masterKubun: { text: "Loại master" },
        ts: { text: "Timestamp" },
        seizoLineCode: { text: "Mã dây chuyền*" },
        seizoLineName: { text: "Dây chuyền" },
        yusenNumber: { text: "Thứ tự*" },
        gramWtNonyu: { text: "Trọng lượng 1 cái" },
        gramMsg: { text: "Giá trị nhập sẽ được chuyển đổi sang Kg" },
        mishiyoFlag: { text: "Không sử dụng" },
        mishiyoFukumuFlag: { text: "Bao gồm KSD", tooltip: "Bao gồm cả dữ liệu không sử dụng"},
        torokuCode: { text: "Người đăng ký" },
        torokuDate: { text: "Ngày giờ đăng ký" },
        cd_shikakari_hin_dlg: { text: "Mã BTP" },
        nm_shikakari_hin_dlg: { text: "Tên BTP", tooltip: "Tên bán thành phẩm"},
        wt_hitsuyo_dlg: { text: "Lượng cần thiết" },
        cd_seihin_shiyodlg: { text: "Mã sản phẩm" },
        dt_seizo_dlg: { text: "Ngày sản xuất" },
        cd_genshizai_dlg: { text: "Mã nguyên vật liệu" },
        nm_genshizai_dlg: { text: "Tên nguyên vật liệu" },
        no_lot_dlg: { text: "Số lô nguyên vật liệu<BR>" },
        dt_niuke_dlg: { text: "Ngày nhận" },
        tm_niuke_dlg: { text: "Thời gian" },
        //dt_kigen_dlg: { text: "Ngày hết hạn" },
        dt_kigen_dlg: { text: "Ngày hết hạn" },
        biko_dlg: { text: "Ghi chú" },
        // 個別ラベル画面
        jyuryoSoShikomi: { text: "Tổng lượng SX", tooltip: "Tổng lượng sản xuất"},
        ritsuBai: { text: "Bội suất" },
        ritsuBaiShort: { text: "Bội suất" },
        suBatch: { text: "Số lượng mẻ" },
        suSeiki: { text: "Mẻ chẵn" },
        suHasu: { text: "Mẻ lẻ" },
        suSeikiKakko: { text: "Chẵn)" },
        suHasuKakko: { text: "Lẻ)" },
        allView: { text: "Tất cả" },
        seikiView: { text: "Mẻ chẵn" },
        hasuView: { text: "Mẻ lẻ" },
        labelInsatsuZen: { text: "In tất cả nhãn" },
        labelInsatsuKo: { text: "In nhãn theo từng cái" },
        suKaishiBatch: { text: "Từ mẻ số" },
        suShuryoBatch: { text: "đến mẻ số" },
        no_kotei_dlg: { text: "Công đoạn" },
        nm_mark_label_dlg: { text: "Mác" },
        nm_genryo_dlg: { text: "Nguyên liệu" },
        wt_kihon_dlg: { text: "Trọng lượng cơ bản" },
        wt_haigo_dlg: { text: "Trọng lượng<br>công thức" },
        nm_tani_shiyo_dlg: { text: "Đơn vị<br>sử dụng" },
        wt_nisugata_dlg: { text: "Trọng lượng<br>đóng gói" },
        nm_nisugata_dlg: { text: "Đóng gói" },
        su_nisugata_kowake_dlg: { text: "Số lượng" },
        wt_kowake1_dlg: { text: "Trọng lượng<br>chia nhỏ 1" },
        su_kowake1_kowake_dlg: { text: "Số gói<br>chia nhỏ 1" },
        nm_futai1_dlg: { text: "Đóng gói 1" },
        wt_kowake2_dlg: { text: "Trọng lượng<br>chia nhỏ 2" },
        su_kowake2_kowake_dlg: { text: "Số gói<br>chia nhỏ 2" },
        nm_futai2_dlg: { text: "Đóng gói 2" },
        shokuba_dlg: { text: "Bộ phận SX", tooltip: "Bộ phận sản xuất" },
        // 印刷選択画面
        insatsuButton: { text: "In" },
        //shikomiKeikauHyo: { text: "Produce list" },
        shikomiKeikauHyo: { text: "Bảng kế hoạch sản xuất" },
        lotKirokuHyo: { text: "Bảng ghi nhận thực tế cân" },
        checkHyo: { text: "Bảng kiểm tra công thức" },
        // ラベルに印字する文字
        txt_kotei_label: { text: "Công đoạn" },
        //txt_kotei_sagyojyun_label: { text: "Order" },
        txt_kotei_sagyojyun_label: { text: "Thứ tự" },
        txt_genryo_label: { text: "Tên nguyên liệu" },
        txt_juryo_label: { text: "Trọng lượng" },
        txt_kaisu_label: { text: "Số mẻ" },
        txt_kosu_label: { text: "Số lần" },
        //txt_shikomi_label: { text: "Produce date" },
        txt_shikomi_label: { text: "Ngày sản xuất" },
        txt_kai_label: { text: "Mẻ" },
        txt_ko_label: { text: "Lần" },
        //txt_kigen_label: { text: "Expiry Date" },
        //txt_kigen_label: { text: "Expiration Date After Opening" },
        txt_kigen_label: { text: "Hạn sử dụng" },
        txt_haigo_label: { text: "Tên công thức" },
        txt_futai_label: { text: "Tên đóng gói" },
        txt_code_label: { text: "Mã nguyên liệu" },
        // ラベルに印字する文字(ver2用)
        txt_titleKowake_label: { text: "NHÃN CHIA NHỎ" },
        txt_titleKasane_label: { text: "NHÃN HỖN HỢP" },
        txt_titleChomi_label: { text: "NHÃN BÁN THÀNH PHẨM" },
        //txt_codeHaigo_label2: { text: "Code" },
        txt_codeHaigo_label2: { text: "Mã công thức" },
        txt_code_label2: { text: "Mã nguyên liệu" },
        txt_genryo_label2: { text: "Tên nguyên liệu" },
        txt_juryo_label2: { text: "Trọng lượng" },
        //txt_haigo_label2: { text: "Formula" },
        txt_haigo_label2: { text: "Tên công thức" },
        //txt_shikomi_label2: { text: "Date" },
        //txt_shikomi_label2: { text: "Production date" },
        txt_shikomi_label2: { text: "Ngày sản xuất" },
        //txt_seizo_label2: { text: "Produce Date" },
        txt_seizo_label2: { text: "Ngày sản xuất" },
        txt_kotei_label2: { text: "Công đoạn" },
        //txt_kotei_sagyojyun_label2: { text: "Order" },
        //txt_kotei_sagyojyun_label2: { text: "Recipe order" },
        txt_kotei_sagyojyun_label2: { text: "Thứ tự" },
        txt_kaisu_label2: { text: "Số mẻ" },
        txt_kosu_label2: { text: "Số lần" },
        txt_maisu_label2: { text: "Số tờ" },
        txt_ritsuBai_label2: { text: "Bội suất" },

        kbn_tani_LB_GAL: { text: "1" },
        kbn_tani_Kg_L: { text: "0" },
        lbl_mark_g: { text: "g" },
        lbl_mark_LB: { text: "LB" },
        lbl_mark_Kg: { text: "Kg" },
        cd_mark: { text: "10" },

        // 品名DLG、取引先DLGの複数選択上限数
        limitMultiSelect: { text: "50" },
        // 実績データ確認ダイアログで使用
        txt_dlg_title: { text: "Sản phẩm có thay đổi" },
        txt_radio_case: { text: "Chỉ cập nhật số C/S" },
        txt_radio_all: { text: "Cập nhật cho tất cả kế hoạch" },
        // 休日ダイアログ
        txt_kyujitsu_kaijyo: { text: "Bỏ ngày nghỉ" },
        
        // トレース画面.品名マスタ検索ダイアログ
        nm_content_dlg: { text: "Nội dung" },
        // 注意喚起ダイアログ
        chuiKankiDialog: { text: "Danh sách chú ý cảnh báo" },
        txt_kbn_chui_dlg: { text: "Loại" },
        txt_nm_chui_dlg: { text: "Tên" },
        cd_chui_dlg: { text: "Mã" },
        nm_chui_dlg: { text: "Tên" },

        // 製造実績選択ダイアログ
        seizoJissekiDialog: { text: "Chọn thực tế sản xuất" },
        date_between: { text: "　～　" },
        seizoJissekiDlg_date: { text: "Ngày" },
        seizoJissekiDlg_shikakari: { text: "Bán thành phẩm" },
        seizoJissekiDlg_code: { text: "Mã" },
        seizoJissekiDlg_hinmei: { text: "Tên" },
        seizoJissekiDlg_seizoSu: { text: "Số lượng sản xuất<br>" },
        seizoJissekiDlg_lotNo: { text: "Lô sản xuất" },
        seizoJissekiDlgn_itemLabel_width: { number: 150 },

        // 仕掛残選択セレクタ
        shikakariZanDlg_date: { text: "Ngày" },
        shikakariZanDlg_nm_shikakari: { text: "Lượng tồn kho" },
        seizoJissekiDlg_seizoSu: { text: "Số lượng sản xuất<br>" },
        seizoJissekiDlg_lotNo: { text: "Lô sản xuất" },

        // 原料ロット選択ダイアログ        
        genryo_sentaku_item_nm_code:  { text: "Mã/ Tên"},
        genryo_sentaku_checkbox_dlg: { text: "Chọn", number: 95 },
        genryo_sentaku_datereceive_dlg: { text: "Ngày nhập dự định", number: 100 },
        genryo_sentaku_datedelivery_dlg: { text: "Ngày nhập thực tế", number: 120 },
        //genryo_sentaku_datedeadline_dlg: { text: "Ngày hết hạn", number: 100 },
        genryo_sentaku_datedeadline_dlg: { text: "Ngày hết hạn", number: 100 },
        genryo_sentaku_lotNo_dlg: { text: "Số lô" },
        genryo_sentaku_lotNo: { text: "Số lô", number: 120 },
        genryo_sentaku_height_table: { number: 170 },

        // 原料ロット取消ダイアログ        
        genryo_item_nm_code: { text: "Mã/ Tên" },
        genryo_dlg_delete: { text: "Hủy", number: 45 },
        genryo_dlg_recei_date: { text: "Ngày nhập dự định", number: 120 },
        genryo_dlg_time: { text: "Ngày nhập thực tế", number: 100 },
        //genryo_dlg_expiry_date: { text: "Ngày hết hạn", number: 100 },
        genryo_dlg_expiry_date: { text: "Ngày hết hạn", number: 100 },
        genryo_dlg_lot_no: { text: "Số lô", number: 110 },
        genryo_dlg_height_table: { number: 175 },

        // 自家原料ロット選択ダイアログ        
        jika_genryo_sentaku_item_name_code: { text: "Mã/ Tên" },
        jika_genryo_sentaku_date: { text: "Ngày sản xuất", number: 135 },
        jika_genryo_sentaku_delete: { text: "Chọn", number: 52 },
        jika_genryo_sentaku_nofpro: { text: "Số lượng sản xuất", number: 135 },
        jika_genryo_sentaku_lotno: { text: "Số lô", number: 118 },
        //jika_genryo_sentaku_exdate: { text: "Ngày hết hạn", number: 100 },
        jika_genryo_sentaku_exdate: { text: "Ngày hết hạn", number: 100 },

        // 自家原料ロット取消ダイアログ        
        jika_genryo_item_nm_code: { text: "Mã/ Tên" },
        jika_genryo_dlg_delete: { text: "Hủy", number: 45 },
        jika_genryo_dlg_manufature_date: { text: "Ngày sản xuất", number: 130 },
        jika_genryo_dlg_no_of_product: { text: "Số lượng sản xuất", number: 135 },
        jika_genryo_dlg_lot_no: { text: "Số lô", number: 110 },
        //jika_genryo_dlg_expiry_date: { text: "Ngày hết hạn", number: 100  },
        jika_genryo_dlg_expiry_date: { text: "Ngày hết hạn", number: 100 },
        
         // 職場選択ダイアログ
        excel:{text: "EXCEL"},
        nm_shokuba_dlg: { text: "Bộ phận SX" },
        cd_shokuba_dlg: { text: "Mã" },
        nm_shokubamei_dlg: { text: "Tên" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noChange: { text: MS0444 },
        notFound: { text: MS0037 },
        changedNotDo: { text: MS0048 },
        flgMishiyo: { text: MS0050 },
        noSelect: { text: MS0443 },
        saveConfirm: { text: MS0064 },
        closeConfirm: { text: MS0066 },
        maxLength: { text: MS0440 },
        noPrintSelect: { text: MS0117 },
        chomiekiLabelPrintConfirm: { text: MS0381 },
        multiSelect: { text: MS0699 },
        noRowSelect: { text: MS0056 },
        noKowakeLabel: { text: MS0706 },
        uploading: { text: "Đang tải lên …" },
        unMatchKasane: { text: MS0717 },
        startDateOverEndDate: { text: MS0019 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        wt_kihon_width: { number: 130 },
        no_kotei_width: { number: 70 },
        wt_nisugata_width: { number: 110 },
        wt_haigo_width: { number: 110 },
        su_nisugata_kowake_seiki_width: { number: 65 },
        su_nisugata_kowake_hasu_width: { number: 65 },
        wt_kowake1_width: { number: 110 },
        su_kowake1_kowake_width: { number: 110 },
        wt_kowake2_width: { number: 110 },
        su_kowake2_kowake_width: { number: 110 },
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        masterKubun: {
            rules: {
                required: "Loại master"
            },
            messages: {
                required: MS0004
            }
        },
        haigoCode: {
            rules: {
                required: "Mã công thức",
                alphanum: true,
                maxbytelength: 14
            },
            messages: {
                required: MS0004,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        cd_line_dlg: {
            rules: {
                required: "Mã dây chuyền",
                alphanum: true,
                maxbytelength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0058
            }
        },
        no_juni_yusen: {
            rules: {
                required: "Thứ tự",
                digits: true,
                range: [1, 99],
                maxbytelength: 2
            },
            messages: {
                required: MS0042,
                digits: MS0005,
                range: MS0009,
                maxbytelength: MS0012
            }
        },
        cd_comment: {
            rules: {
                required: "Mã",
                maxbytelength: 2
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        comment: {
            rules: {
                required: "Chú thích",
                maxbytelength: 100
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        gramWtNonyu: {
            rules: {
                number: true,
                range: [0, 999999999.999],
                pointlength: [9, 3, false]
            },
            messages: {
                number: MS0441,
                range: MS0450,
                pointlength: MS0440
            }
        },
        suKaishiBatch: {
            rules: {
                required: "Từ mẻ số",
                number: true,
                range: [1, 99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        suShuryoBatch: {
            rules: {
                required: "đến mẻ số",
                number: true,
                range: [1, 99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450,
                custom: MS0553
            }
        },
        hizuke: {
            rules: {
                required: "Ngày bắt đầu",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                //greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                //greaterdate: MS0247
            }
        },
        hizuke_from: {
            rules: {
                required: "Ngày bắt đầu",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247
            }
        },
        hizuke_to: {
            rules: {
                required: "Ngày kết thúc",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247
            }
        },
        ///begin genryo lot sentaku dialog
        dt_niuke_start: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31"),
                greaterdate_niuke_from: ["Ngày nhận kế hoạch (bắt đầu)", "Ngày nhận kế hoạch (kết thúc)"]
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247,
                greaterdate_niuke_from: MS0019
            }
        },
        dt_niuke_end: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        dt_yotei_niuke_start: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31"),
                greaterdate_yoteiniuke_from: ["Ngày nhập thực tế (từ)", "Ngày nhập thực tế (đến)"]
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247,
                greaterdate_yoteiniuke_from: MS0019
            }
        },
        dt_yotei_niuke_end: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        ///end genryo lot sentaku dialog
        ///begin jika genryo lot sentaku dialog
        dt_seizo_start:{
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31"),
                greaterdate_from: ["Ngày sản xuất (từ)", "Ngày sản xuất (đến)"]
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247,
                greaterdate_from: MS0019
            }
        },
        dt_seizo_end: {
            rules:{
                datestring: true,
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages:{
                datestring: MS0247,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        ///end jika genryo lot sentaku dialog
        no_lot_search:{
            rules: {
                maxbytelength: 14
            },
            messages: {
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

})();