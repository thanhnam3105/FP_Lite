(function () {
    // visible が未設定の場合は表示
    // visible が "*" の場合は権限確認しない
    // visible が "*" 以外の場合は、一致する role だけに表示
    // visible が配列の場合は、一致する role が含まれている場合だけ表示
    // visible が関数の場合は、戻り値として true が返ってきた場合だけ表示
    App.ui.ddlmenu.settings("vi", "Menu", [

        {
            display: "Menu quản lý sản xuất",
            items: [
                { display: "Tạo kế hoạch sản phẩm theo tháng", url: "../Pages/GekkanSeihinKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Tạo kế hoạch bán thành phẩm theo tháng", url: "../Pages/GekkanShikakarihinKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Kế hoạch bán thành phẩm theo ngày", url: "../Pages/ShikakarihinShikomiKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Danh sách chưa đăng ký dây chuyền", url: "../Pages/LineMitorokuIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Yêu cầu xuất kho", url: "../Pages/GenryoShiyoryoKeisan.aspx", visible: ["Admin", "Manufacture", "Purchase"] }
                //{ display: "Tính toán lượng sử dụng vật liệu", url: "../Pages/ShizaiShiyoryoKeisan.aspx", visible: ["Admin", "Manufacture", "Purchase"] }
            ],
            visible: ["Admin", "Manufacture", "Purchase", "Quality"]
        },
        {
            display: "Menu nguyên vật liệu",
            items: [
                { display: "Bảng biến động", url: "../Pages/GenshizaiHendoHyo.aspx" },
                { display: "Cảnh báo tồn kho", url: "../Pages/KeikokuListSakusei.aspx", visible: ["Admin", "Purchase", "Warehouse"] },
            //SAP対応の為非表示
                //{ display: "Lập kế hoạch nhập nguyên vật liệu", url: "../Pages/GenshizaiNonyuKeikakuSakusei.aspx", visible: ["Admin", "Purchase"] },
                { display: "Tạo đơn yêu cầu mua hàng", url: "../Pages/NonyuIraishoSakusei.aspx", visible: ["Admin", "Purchase"] },
                { display: "Tạo kế hoạch mua hàng", url: "../Pages/NonyuYoteiListSakusei.aspx", visible: ["Admin", "Purchase"] },
                { display: "Mô phỏng bảng biến động", url: "../Pages/HendoHyoSimulation.aspx", visible: ["Admin", "Purchase"] },
                { display: "Danh sách tổng hợp lượng sử dụng", url: "../Pages/GenshizaiShikakarihinShiyoIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Chi tiết lịch sử biến động", url: "../Pages/GenshizaiUkeharaiIchiran.aspx", visible: ["Admin", "Manufacture", "Quality", "Purchase", "Warehouse"] }
            ]
        },
        {
            display: "Menu báo cáo thực tế",
            items: [
                { display: "Thực tế sản xuất sản phẩm", url: "../Pages/SeizoNippo.aspx", visible: ["Admin", "Manufacture", "Purchase"] },
                { display: "Thực tế sản xuất bán thành phẩm", url: "../Pages/ShikomiNippo.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Liên kết dữ liệu (với SAP)", url: "../Pages/ShiyoJissekiIkkatsuDenso.aspx", visible: ["Admin", "Manufacture"] },
                { display: "Nhập dữ liệu điều chỉnh", url: "../Pages/GenshizaiChoseiNyuryoku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Warehouse"] },
                { display: "Nhập tồn kho thực tế", url: "../Pages/GenshizaiZaikoNyuryoku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Warehouse"] }
            ],
            visible: ["Admin", "Manufacture", "Purchase", "Warehouse"]
        },
        {
            display: "Menu tính đơn giá",
            items: [
                { display: "Danh sách đơn giá", url: "../Pages/GenkaIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Tính đơn giá", url: "../Pages/GenkaTankaSakusei.aspx", visible: ["Admin", "Purchase"] }    
            ],
            visible: ["Admin", "Purchase"]
        },
        {
            display: "Menu master cơ bản",
        items: [
                { display: "Master nguyên vật liệu", url: "../Pages/HinmeiMasterIchiran.aspx", 
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality"]
                        if (App.ui.page.user.kbn_ma_hinmei != pageLangText.isRoleHinmei.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "Master công thức", url: "../Pages/HaigoMasterIchiran.aspx",
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality"]
                        if (App.ui.page.user.kbn_ma_haigo != pageLangText.isRoleHaigo.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "Master thiết lập dây chuyền sản xuất", url: "../Pages/SeizoLineMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Master vật tư sử dụng", url: "../Pages/ShizaiShiyoMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Master khách hàng", url: "../Pages/TorihikisakiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Master thiết lập nhà cung cấp", url: "../Pages/GenshizaiKonyusakiMaster.aspx",
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality", "Warehouse"] 
                        if (App.ui.page.user.kbn_ma_konyusaki != pageLangText.isRoleKonyusaki.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "Master nhân viên", url: "../Pages/TantoshaMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "Master lịch năm", url: "../Pages/NenkanCalendarMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Master công ty", url: "../Pages/KaishaMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Master nhà máy", url: "../Pages/KojoMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Master bộ phận sản xuất", url: "../Pages/ShokubaMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "Master dây chuyền sản xuất", url: "../Pages/LineMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "Master phân loại nhóm", url: "../Pages/BunruiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Master đơn vị", url: "../Pages/TaniSetteiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Master vị trí", url: "../Pages/LocationMaster.aspx",
                    visible: function (role) {
                        // role ? ["Admin", "Manufacture", "Purchase"]
                        if (App.ui.page.user.locationCode == pageLangText.locationKbn_nasi.number) {
                            return false;
                        } else {
                            return true;
                        }
                    }
                },
                // ■仕掛残計上機能OFF対応(機能ONは下のコメントアウトをオープンして下さい):メニューからのリンク削除
                { display: "Usable Inventory Master", url: "../Pages/ShikakarizanShiyoKanoMaster.aspx", visible: [/*"Admin", "Quality"*/] }
            ]
    },
        {
            display: "Menu master phụ",
            items: [
                { display: "Master kho xuất", url: "../Pages/KurabashoMaster.aspx", visible: ["Admin", "Purchase", "Warehouse"] },
                { display: "Master nơi nhận hàng", url: "../Pages/NiukeBashoMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Master phân loại nơi nhận hàng", url: "../Pages/NiukeBashoKubunMaster.aspx", visible: ["Admin", "Quality", "Purchase", "Warehouse"] },
                { display: "Master điều kiện bảo quản", url: "../Pages/HokanKubunMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Master chỉ thị sản xuất", url: "../Pages/ShikomiSagyoShijiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Master kiểu đóng gói", url: "../Pages/FutaiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Master quy định kiểu đóng gói", url: "../Pages/FutaiKetteiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Master thiết lập trọng lượng", url: "../Pages/JuryoMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Master chú ý cảnh báo", url: "../Pages/ChuiKankiMaster.aspx", visible: ["Admin", "Manufacture", "Quality", "Warehouse"] },
            	{ display: "Master nguyên liệu chú ý cảnh báo", url: "../Pages/GenryoChuiKankiMaster.aspx", visible: ["Admin", "Manufacture", "Quality", "Warehouse"] },
                { display: "Master lý do", url: "../Pages/RiyuMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Master bộ phận phát sinh chi phí", url: "../Pages/GenkaCenterMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Master kho chứa", url: "../Pages/SokoMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Chi tiết lịch sử cập nhật", url: "../Pages/HistoryChangeMaster.aspx" }
            ]
        }
        /*
        {
            display: "Transmission History Menu",
            items: [
                { display: "Manufacturing Planning Transmission List", url: "../Pages/SeizoKeikakuDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Manufacturing Results  Transmission List", url: "../Pages/SeizoJissekiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Delivery Schedule Transmission List", url: "../Pages/NonyuYoteiDensoIchiran.aspx.aspx", visible: ["Admin", "Purchase"] },
                { display: "Delivery Record Transmission List", url: "../Pages/NonyuJissekiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Stock Adjustment Transmission List", url: "../Pages/ZaikoChoseiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Month-end Stocktaking Transmission List", url: "../Pages/GetsumatsuZaikoDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "BOM Master Transmission List", url: "../Pages/BomMasterDensoIchiran.aspx", visible: ["Admin", "Purchase"] }
            ],
            visible: ["Admin", "Purchase"]
        }
        */
    /*
    {
    display: "システムロール専用メニュー",
    visible: function (role) {
    return !!/^sys.*$/i.test(role);
    },
    url: "http://www.google.com"
    }
    */
    ]);

})(App);
