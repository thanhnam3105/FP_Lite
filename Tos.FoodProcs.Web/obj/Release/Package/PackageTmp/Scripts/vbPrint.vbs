        'IEのみ　選択されているプリンタに直接印刷
        Sub PrintX()
               OLECMDID_PRINT = 6
               OLECMDEXECOPT_DONTPROMPTUSER = 2
               OLECMDEXECOPT_PROMPTUSER = 1
               call WB.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_DONTPROMPTUSER,1)
        End Sub
        document.write "<object ID='WB' WIDTH=0 HEIGHT=0 CLASSID='CLSID:8856F961-340A-11D0-A96B-00C04FD705A2'></object>"
