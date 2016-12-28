# encoding: utf-8

module BackupSpec
  GPGKeys = Hash.new { |h, k| h[k] = {} }

  GPGKeys[:backup01][:long_id] = "8F5D150616325C61"
  GPGKeys[:backup01][:public] = <<-EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    Version: GnuPG v1.4.12 (GNU/Linux)

    mI0EUBR6CwEEAMVSlFtAXO4jXYnVFAWy6chyaMw+gXOFKlWojNXOOKmE3SujdLKh
    kWqnafx7VNrb8cjqxz6VZbumN9UgerFpusM3uLCYHnwyv/rGMf4cdiuX7gGltwGb
    dwP18gzdDanXYvO4G7qtk8DH1lRI/TnLH8wAoY/DthSR//wcP33GxRnrABEBAAG0
    HkJhY2t1cCBUZXN0IDxiYWNrdXAwMUBmb28uY29tPoi4BBMBAgAiBQJQFHoLAhsD
    BgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRCPXRUGFjJcYZc5A/91HQ4+BXUw
    KUHmpGyD+6b42xl3eBdmBVimCYTgfRUyRQEDWzHV4a3cYWwe30J/LzfFn1E6uVwz
    6SHtzwZddWwONRgC/Q7V0TrnLeuv46MKoB24EFqfbr0kosuZgHPuK4h+rLmaPVCM
    kv9DcKCupGnFzoaZ7tdgQAXzGepZQZU0sbiNBFAUegsBBACXX6cGjaENoOMyibXh
    HLlEOKWwlxDgo3bSu6U8kISUmwxH/MO4I/u7BAQBczitNYSWovlbvCcxCy4h12qj
    gruN5INIDGsEfDSWcN3lxBZ+9J+FhngBjETeADFaPxoele9wVGdIYdLIP6RntK/D
    6F2ER8sb57YYtK50iyyuYQqSeQARAQABiJ8EGAECAAkFAlAUegsCGwwACgkQj10V
    BhYyXGEq7AP/Y/k1A6nrCC6bfkHFMJmEJDe0Wb6q8P3gcBqNuf8iOwk53UdoXU0Q
    JcPAQd/sJy6914huN2dzbVCSchSkLRXgejI0Xf5go1sDzspVKEflu0CWZ3A976QH
    mLekS3xntUhhgHKc4lhf4IVBqG4cFmwSZ0tZEJJUSESb3TqkkdnNLjE=
    =KEW+
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
  GPGKeys[:backup01][:private] = <<-EOS
    -----BEGIN PGP PRIVATE KEY BLOCK-----
    Version: GnuPG v1.4.12 (GNU/Linux)

    lQHYBFAUegsBBADFUpRbQFzuI12J1RQFsunIcmjMPoFzhSpVqIzVzjiphN0ro3Sy
    oZFqp2n8e1Ta2/HI6sc+lWW7pjfVIHqxabrDN7iwmB58Mr/6xjH+HHYrl+4BpbcB
    m3cD9fIM3Q2p12LzuBu6rZPAx9ZUSP05yx/MAKGPw7YUkf/8HD99xsUZ6wARAQAB
    AAP/VJDiogUAjtK7SNH4BcU6qjxWK4pyQkcE8LcOvKbn48bcXtJrtg7GWpYrNxjI
    Mg/nHHt6Lpkqg3RmI0ILMzOj5TukhmJnB/ieogFyuiVzymcMdkcx8PRNXIoF90Au
    8yp5ZgXdStmIrlxh4ofJsas8YWsVynb+r6FT2UrAjYT3vAECANoCF26P14ZtGQJ4
    eT4a19wzlcIDMuKFaXlB5WYCnQi43ngKn/mjdQrNfpfSPNF+oCHlWGisz0fg/51+
    NXg46+sCAOe1pm8K6qO20SzkAW0b9Hzk0b0JWJiHk1QiB1gR9KZffC/8Y7rqYaiG
    Sbtyc3ujjayFdc90bwZeSkzrCvO/CgEB/3jiuZiAOov2JFMMPzp7S9SS3CN8nopp
    xupeE6uH3Kxp24XYgLxfRO9iqZK/BRlkb5fUKw8u08J5439X9o9mBUOf4bQeQmFj
    a3VwIFRlc3QgPGJhY2t1cDAxQGZvby5jb20+iLgEEwECACIFAlAUegsCGwMGCwkI
    BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEI9dFQYWMlxhlzkD/3UdDj4FdTApQeak
    bIP7pvjbGXd4F2YFWKYJhOB9FTJFAQNbMdXhrdxhbB7fQn8vN8WfUTq5XDPpIe3P
    Bl11bA41GAL9DtXROuct66/jowqgHbgQWp9uvSSiy5mAc+4riH6suZo9UIyS/0Nw
    oK6kacXOhpnu12BABfMZ6llBlTSxnQHYBFAUegsBBACXX6cGjaENoOMyibXhHLlE
    OKWwlxDgo3bSu6U8kISUmwxH/MO4I/u7BAQBczitNYSWovlbvCcxCy4h12qjgruN
    5INIDGsEfDSWcN3lxBZ+9J+FhngBjETeADFaPxoele9wVGdIYdLIP6RntK/D6F2E
    R8sb57YYtK50iyyuYQqSeQARAQABAAP6Akx2AvtBheKqnJIl3cn5FWxWS3Q/Jygi
    +2rVJNJYKbu2hVJ/xDMLWoZNC3AXsof95X3f/e4sJVpN/FPS/IdqqBmZpREOzash
    fWAjs6j7Z7lQEuxKvdSdcy4olzcYGOegYaZpL0B9eeOtX3Hb4JXHwp0i9NwFlXgg
    MR10rIy48qECAMBEW64UAaZ31/Q1P0NXfMYTm+vogrAi8lsVdSAjDBAKtAD3+mGD
    JGymg0R6uzw9xDijN9HgBi55TfCAiVoVhiECAMmNHHuypUMVsPstBtUEELwDHH7K
    acWFNhi6x4Ccl1C7xncKK6BedjjwP8K06hBjWAkBzNUwX79N0Lm+ob9O0VkB+wdE
    ykurS0qEob/PiLBA5ksWRA1EKLQ/PjEmSxYJAldVLyKtUPtfyXVKTpZ2xCwuLi/m
    sspaiPeTJp7Gtr1l/smYf4ifBBgBAgAJBQJQFHoLAhsMAAoJEI9dFQYWMlxhKuwD
    /2P5NQOp6wgum35BxTCZhCQ3tFm+qvD94HAajbn/IjsJOd1HaF1NECXDwEHf7Ccu
    vdeIbjdnc21QknIUpC0V4HoyNF3+YKNbA87KVShH5btAlmdwPe+kB5i3pEt8Z7VI
    YYBynOJYX+CFQahuHBZsEmdLWRCSVEhEm906pJHZzS4x
    =ls9W
    -----END PGP PRIVATE KEY BLOCK-----
  EOS

  GPGKeys[:backup02][:long_id] = "711899386A6A175A"
  GPGKeys[:backup02][:public] = <<-EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    Version: GnuPG v1.4.12 (GNU/Linux)

    mI0EUBR6JQEEAMPuY4qoKR7MpZA7D+KRrhiJRCT8t5F4IZ+gq7FBCfwoopcStlin
    nTGRL1F/UEngu5xHgLsERzPdKNoTpoy1aCcgB7i9vyi2bA3iNGs1YzWqf1vGJxEp
    +CXXtlBU+QYod6wRMK4cHKVjPaD+Ga+saU1Pz9tBGYAbADYVmhJd7R21ABEBAAG0
    HkJhY2t1cCBUZXN0IDxiYWNrdXAwMkBmb28uY29tPoi4BBMBAgAiBQJQFHolAhsD
    BgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRBxGJk4amoXWjJxA/sG60qZMn40
    IP0pjuY+3kc5199xcavxgHZdQTBq2vrJHzr3K8Zk8xxSCADRJf4++t4+8yG7g9rk
    bmEAeGoFBIbdx7zGcxYIe5g9UG/+eDCJ44HCb0v8vHUT7iqt5Jk6cryYtcYvqO6I
    84HXdXz4rCMCUeRP4ceMCZB6GZKDXR8zoriNBFAUeiUBBADEEOUdfCmwJ5BEPWzm
    QTGcp2dSY8SgpbZtk23LvWIlEziYflIqOGeL623AOBb9S2FChR+zPyOA9D3LEZrA
    PF8TS3YY+qjBdiXLKchRr5y2Kwylh/vVdcCcgTjfPkga4pGq+cHBOevPiqAvoCtO
    ntN7+Cqk3B7nWTPQRFDQJVThwwARAQABiJ8EGAECAAkFAlAUeiUCGwwACgkQcRiZ
    OGpqF1oNNgP/adkSZZVaYy/JEHjjrtC9UwirSluAdHQZGPGv/FHaFou+4mlLi0+R
    gQLieU+3AHFSWVYMNjIsSjA4hhMLchteFlJnbkGAFUaA2QUoyf7cSSmdpNKQdDdZ
    oe3OXEQM2pUTEwE9AqKXthrSMQuJ5bozm8zHm/CohZPHGTeQH75Kq/4=
    =AgbQ
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
  GPGKeys[:backup02][:private] = <<-EOS
    -----BEGIN PGP PRIVATE KEY BLOCK-----
    Version: GnuPG v1.4.12 (GNU/Linux)

    lQHYBFAUeiUBBADD7mOKqCkezKWQOw/ika4YiUQk/LeReCGfoKuxQQn8KKKXErZY
    p50xkS9Rf1BJ4LucR4C7BEcz3SjaE6aMtWgnIAe4vb8otmwN4jRrNWM1qn9bxicR
    Kfgl17ZQVPkGKHesETCuHBylYz2g/hmvrGlNT8/bQRmAGwA2FZoSXe0dtQARAQAB
    AAP9Ek+8U+Alf7BmpNUwRd+Ros9pY/+OdHUCx3VvtnA6q6tsjqv8CMsZgOFtx7Mb
    YNw1DIUOPexHb0xzHfaKMUpfAmc4PRYnEiggloT+UmB/Hs2tHfeE3hONiDDD9PMU
    PiFmm2d+P0pRVTZUrioBaACWpu5YS03I6SC0zDdJeJapk10CANvaaRUZwBqpccfR
    MFuV78NYPDkgwKuIJzMRFvp2PnEYPKmS7Ivz5ZimwltDukEOdmTCUAjW6iibKav5
    EFmENSMCAOQlGzr3kQRNbcTWh4MYqQ0mDS0Gv9IWZR1DJBPziWnaMqvMyRrFK031
    WXzHFDkhbph/HjZ0M33e7bsaLfBsq0cB/Ag+/9rJyTAOyCgbx4VNeipuseiLW3rn
    gE5UdJa2FHpZcJqHk81IssCTVLnU3NADH0Eg6rVB4/31L1CtlkxgxZiXWbQeQmFj
    a3VwIFRlc3QgPGJhY2t1cDAyQGZvby5jb20+iLgEEwECACIFAlAUeiUCGwMGCwkI
    BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEHEYmThqahdaMnED+wbrSpkyfjQg/SmO
    5j7eRznX33Fxq/GAdl1BMGra+skfOvcrxmTzHFIIANEl/j763j7zIbuD2uRuYQB4
    agUEht3HvMZzFgh7mD1Qb/54MInjgcJvS/y8dRPuKq3kmTpyvJi1xi+o7ojzgdd1
    fPisIwJR5E/hx4wJkHoZkoNdHzOinQHXBFAUeiUBBADEEOUdfCmwJ5BEPWzmQTGc
    p2dSY8SgpbZtk23LvWIlEziYflIqOGeL623AOBb9S2FChR+zPyOA9D3LEZrAPF8T
    S3YY+qjBdiXLKchRr5y2Kwylh/vVdcCcgTjfPkga4pGq+cHBOevPiqAvoCtOntN7
    +Cqk3B7nWTPQRFDQJVThwwARAQABAAP0CszwvLeNuTt80e53OXmOmYJZ6zhzRz2k
    kiX+LwzoRKjYycFdFz3gCqiDj9w1Pq6Pcx030Wmh+tI07znhkXGG6WgEdg3WMBa0
    ephoNZKsmU2Xhbpf/au8uNwXLtaCEgZoC04JGlGzbX4gJXyUooW+/paxZMQFWFlM
    ztf04oIHFQIA2+wOHvJc3HxP0I1Gtfx9bf27UKp1O/4te3m8yOZuIb8gAhlvqkJr
    q+HcJ6604c8vKBHA08F+E6EJ8Sdt/eMlTwIA5Dr4AmGEKqkk92FuXm6R0ruo9Bm3
    Ep7eFCjRul5lKV/lTF88+KLrzMzho1E/9BgiOKvm7Z1yQTZQUAHEwcqHTQIAusG5
    gr2CASWpXbCxX6DWl8n7hdWAhGR0wHWk3ValNl0hLzxMx2Icf2ZWZ3rZw2/JsLiQ
    oujz1T1DWgxsNyZaraPsiJ8EGAECAAkFAlAUeiUCGwwACgkQcRiZOGpqF1oNNgP/
    adkSZZVaYy/JEHjjrtC9UwirSluAdHQZGPGv/FHaFou+4mlLi0+RgQLieU+3AHFS
    WVYMNjIsSjA4hhMLchteFlJnbkGAFUaA2QUoyf7cSSmdpNKQdDdZoe3OXEQM2pUT
    EwE9AqKXthrSMQuJ5bozm8zHm/CohZPHGTeQH75Kq/4=
    =+a/7
    -----END PGP PRIVATE KEY BLOCK-----
  EOS

  GPGKeys[:backup03][:long_id] = "5847D49DD791E4FA"
  GPGKeys[:backup03][:public] = <<-EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    Version: GnuPG v1.4.12 (GNU/Linux)

    mI0EUBR4LgEEAL6TxhYYNEirawnp/fmc0TwKYVSiTk60qGJyspEj0QKJ3MmunC/o
    YX+5k8HN68BKP7xkJyHYFdXCJn2HqSbj0T7oV4scQGLJSO5adNa/6uMDZIA6Ptt4
    UFOwdc8bnV9sDQTdrp2Gqsxi3f34WX0DV7/KrMD/jQJ9hiWphXSmvaV9ABEBAAG0
    HkJhY2t1cCBUZXN0IDxiYWNrdXAwM0Bmb28uY29tPoi4BBMBAgAiBQJQFHguAhsD
    BgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRBYR9Sd15Hk+shkA/4yev3zyK+/
    jPZQgFLq10biRDYMdWk4ysHCkSbBi4GMnjIanBFk6ggbH/jQIb79oZRv2MB/N8Ag
    4s1oZdC5W1gSCg4m4pUB06NkKD4NvKAHHzsfr93farAct1zBQJ19e2ErFeo2Bb5G
    uAvf2VWziMQD9aB0lF6tf/CToeWp+2xK77iNBFAUeC4BBADGwKc66SFldjN9dIxk
    NYWLwCSvEgsOUdQpYckWLeUFnvKMpOW9+0Q5fc7QZuTs4TnT6cHjKk7F4ZQpMlqy
    vc5H99vfp+/fus4LyAYIZKXmuc44SWwxU0y2MsGguFZbWKctQLquKD3uk3S8LPvY
    wYn5weLVOhoUgbYGi6HeK8hkuQARAQABiJ8EGAECAAkFAlAUeC4CGwwACgkQWEfU
    ndeR5PqQIQP8DMrzFSpyOEsxWRC8x4dhBtpptjO2MIS9FsX9pmycC52V9mCQX5pb
    5ZN6YPHOArYNUQfrXGRrOQFAPuNaucet/w39KIOmMZGPRGzOkTmp4AEhO7fKtuw8
    /oWOO6hlX/rG4JNZUu3DQEt8WKCV9dHGxNWkxEptRA/CRYW4aj0MkaE=
    =dxCg
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
  GPGKeys[:backup03][:private] = <<-EOS
    -----BEGIN PGP PRIVATE KEY BLOCK-----
    Version: GnuPG v1.4.12 (GNU/Linux)

    lQHYBFAUeC4BBAC+k8YWGDRIq2sJ6f35nNE8CmFUok5OtKhicrKRI9ECidzJrpwv
    6GF/uZPBzevASj+8ZCch2BXVwiZ9h6km49E+6FeLHEBiyUjuWnTWv+rjA2SAOj7b
    eFBTsHXPG51fbA0E3a6dhqrMYt39+Fl9A1e/yqzA/40CfYYlqYV0pr2lfQARAQAB
    AAP9HVrYQHd+eDIVRPvqr7vwu7mSl+1/N97ab/2gVTxp2aUAIf24F6YI/JpKcOgF
    2ALn0d4wa+VjqZ8j/CJ9Et01EeIkEl9rDBVHLFKLpEABSRCCPpYPBhNqKgRQnLBl
    M9kb6OxlBF0Y2L7oonq19Txer8FNB724m7yvBlWQko5id6ECAND9Cgn/YVuj83Es
    DEBMjyAysgs3L69CoKQRL02PULbfVgabKqKqFJKDZr4DVyVo6v0L/c9pvnrz5GZG
    McGH390CAOlyfn9fWtNjMci+DZ2ZXjut8FXnU+ChyGoc62brcQ0YE1767pyIpmxe
    sG06jTMPpmBSA1xbMpScfLQehnLJUiEB/3f3U/8UiUTmB8bWe2JpHefJAn3Y8VLr
    tLXujEmYqrn6kUNo1UgIodLtlKY/HfYm6gvcBl5W4+z7FnDBWwDIlX6e/7QeQmFj
    a3VwIFRlc3QgPGJhY2t1cDAzQGZvby5jb20+iLgEEwECACIFAlAUeC4CGwMGCwkI
    BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEFhH1J3XkeT6yGQD/jJ6/fPIr7+M9lCA
    UurXRuJENgx1aTjKwcKRJsGLgYyeMhqcEWTqCBsf+NAhvv2hlG/YwH83wCDizWhl
    0LlbWBIKDibilQHTo2QoPg28oAcfOx+v3d9qsBy3XMFAnX17YSsV6jYFvka4C9/Z
    VbOIxAP1oHSUXq1/8JOh5an7bErvnQHYBFAUeC4BBADGwKc66SFldjN9dIxkNYWL
    wCSvEgsOUdQpYckWLeUFnvKMpOW9+0Q5fc7QZuTs4TnT6cHjKk7F4ZQpMlqyvc5H
    99vfp+/fus4LyAYIZKXmuc44SWwxU0y2MsGguFZbWKctQLquKD3uk3S8LPvYwYn5
    weLVOhoUgbYGi6HeK8hkuQARAQABAAP9G+yT4lFAXbC8fb8a/XZOl8qsbMN4da/W
    AuVn+vuCPqatFckSNT3BAWHVZY7bUZO4S/d/A/NdA2zU4+/c8dl8inzv5tAmVFQY
    w9XYZoA8d4GS+IflmVAzu8aWJlQLfMI8HKtwrf4gpSjZFsLIe9E/xQSgGWt1WXJ5
    fbgbBKBLRB0CANF5C0VHOg/zIc7AODCi9GYqYWxQE0MiMhh1SzuG/NVHke+ldhqb
    ogV+TMBAR8PCRNf64cKtXyJ2u5ZnXlSBWdUCAPLmCZBCFW3hm/26fdAovNHA53HZ
    ucxhwrLP0Ks1+vr779JMypl6QVYbbHXaI7oyRFKg5KOdz4S2ij213gVOzVUCAKy1
    MftwhFXCrQwfuA8d2rnro4WqreNyzRj/7QL11N8oQ1XasHCuuOVpDVyuBxtwGLG3
    KUeriIODL6Bo/RevX0an8YifBBgBAgAJBQJQFHguAhsMAAoJEFhH1J3XkeT6kCED
    /AzK8xUqcjhLMVkQvMeHYQbaabYztjCEvRbF/aZsnAudlfZgkF+aW+WTemDxzgK2
    DVEH61xkazkBQD7jWrnHrf8N/SiDpjGRj0RszpE5qeABITu3yrbsPP6FjjuoZV/6
    xuCTWVLtw0BLfFiglfXRxsTVpMRKbUQPwkWFuGo9DJGh
    =6CYb
    -----END PGP PRIVATE KEY BLOCK-----
  EOS

  GPGKeys[:backup04][:long_id] = "0F45932D3F24426D"
  GPGKeys[:backup04][:public] = <<-EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    Version: GnuPG v1.4.12 (GNU/Linux)

    mI0EUBR40wEEAMLAMVwpXCeEz1QZPJc8RFwAUBZRc/FYZ+CY4RKfQKZPuBMyzz3y
    mk3gFB8raw2nycH00zwrP/qm/gIBzpCza+87uqGrB8bezgHoU1CaFnO0ZNUzyB8j
    FsaQ/7BScjFNQp4RvbryZJUMXJ0V8fV9mQMe+O83CskabLCS4UY6EhWXABEBAAG0
    HkJhY2t1cCBUZXN0IDxiYWNrdXAwNEBmb28uY29tPoi4BBMBAgAiBQJQFHjTAhsD
    BgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRAPRZMtPyRCbU30A/0YU8U7EOKd
    5jSKhkAN50n4Cvwr0uOfC3UoJHInglRc+hDLB5ZF5GMqSfLYIb6/saY99Xb76l7i
    k/0Q+rpk0AJ/dbY2ARrPqetleTPBsjrQbj9pzU4yvpYohpippjUbGAo74ssRGJoX
    28O98TXn8+q3bcz7bbLBmYj1Fy4QrSpBj7iNBFAUeNMBBADNBWFF0UFiPOCh9g3P
    qOAYOXRsmEpLwGBGUB5ZdWzkIGrvs3KjTxIgy+uvx5Q8nX7+OLePaR9BM0qyryzz
    LLjEKuaeDk1KelZ6/aV4ErgBUfVDs8pniLrSUqD65o18PL+T6nQ4aUYpgcqdb7t/
    /by/yzt0+eEaAoArm0B8IdzB/QARAQABiJ8EGAECAAkFAlAUeNMCGwwACgkQD0WT
    LT8kQm2LDgP/cUpWPR/GVdwLlbUIWBh37lLHEEuppZFg2P15Pv0UK9pNxCFhGouS
    eBXW8xC/mvOrf7mj/tEV3CxGvIFdebtraEwLUQW0109vWHNclK6/SvmSNcaPo1t0
    FtsIP4HI4ymvvTKUObfQliRdk1u1wY7sCWGarQgN9NtHuuyYP5+wmYg=
    =LfdH
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
  GPGKeys[:backup04][:private] = <<-EOS
    -----BEGIN PGP PRIVATE KEY BLOCK-----
    Version: GnuPG v1.4.12 (GNU/Linux)

    lQHYBFAUeNMBBADCwDFcKVwnhM9UGTyXPERcAFAWUXPxWGfgmOESn0CmT7gTMs89
    8ppN4BQfK2sNp8nB9NM8Kz/6pv4CAc6Qs2vvO7qhqwfG3s4B6FNQmhZztGTVM8gf
    IxbGkP+wUnIxTUKeEb268mSVDFydFfH1fZkDHvjvNwrJGmywkuFGOhIVlwARAQAB
    AAP8C0NOjNFu3Rw5r1fsS092y/P6rb0VMv0quMWup+3iMRwa0wVqZd9CHESGyrdZ
    8BwRjNrfXTNKdnEHmfnHxqeRvit+WRPCuhGcRTNJ8UTBPw4XMY/UYXHIXQGXwqk6
    lzd+UQvqyZPv3ukuChDrXuCTG+443WFfHxl4S7PAn3aTwjUCANQjjqSweQZAHvn0
    XXcnTNRDV8Bf+Sl7rxhMcBUJhFu3ALBWosZDI/zYTDQ/FZqbM8A9Poh6cnB2TS/S
    47kNwDMCAOsESXIs/RBg2RDactjqxj5TVn/T0PMZ1AhV2BPl2RmP/bnwyBWy0O9N
    V3hKY0ArEEpcNf8HuRz7/nOduCtEYQ0CAN2AODbYyG/sL+wH0k392fpnsWmdYs4N
    21AgfPY8U3Oyrodgjz1hU3C3dxyE3co4sU42d3sLI2tpxa0xy6mHetKdbLQeQmFj
    a3VwIFRlc3QgPGJhY2t1cDA0QGZvby5jb20+iLgEEwECACIFAlAUeNMCGwMGCwkI
    BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEA9Fky0/JEJtTfQD/RhTxTsQ4p3mNIqG
    QA3nSfgK/CvS458LdSgkcieCVFz6EMsHlkXkYypJ8tghvr+xpj31dvvqXuKT/RD6
    umTQAn91tjYBGs+p62V5M8GyOtBuP2nNTjK+liiGmKmmNRsYCjviyxEYmhfbw73x
    Nefz6rdtzPttssGZiPUXLhCtKkGPnQHYBFAUeNMBBADNBWFF0UFiPOCh9g3PqOAY
    OXRsmEpLwGBGUB5ZdWzkIGrvs3KjTxIgy+uvx5Q8nX7+OLePaR9BM0qyryzzLLjE
    KuaeDk1KelZ6/aV4ErgBUfVDs8pniLrSUqD65o18PL+T6nQ4aUYpgcqdb7t//by/
    yzt0+eEaAoArm0B8IdzB/QARAQABAAP9H1IfFidtsbBTMOsCGSNXeNvuKVjqoL/2
    9UbwHAKQbBl3vL7RWJmPz2rXyrbWspvs9rF7eXE50SAg3UNdvpiqcSdBwC4VSDNe
    VSbKaZ5MmqapC7ioLH/FEcvZgaZfTsTsLC10CIZgisW+z+zKq2fafwSI5o2XMuoE
    /iuai9z6ZoECANEKpjytZB93+O2fUWPG7BjIzVUZGIeSxGKPze9jgQloHAou5sH8
    WygPVlQzy9Xxt7Z9/QrZlGdalyeDQaoC6dkCAPsThN0K0s2pabEfMtYOneJzR5Xs
    ze6aqs6+FpHikAISMswd5EHnfPtKA51bGxWKAxgeCqNMpf8tJMAFCmj2fsUB/3Z5
    IZJE+OmdiMDm81yDNpK801RZAiySpbZ5CEaWB/BuuTIyG7k/dtSnWtodEOEcEjFs
    yBaY+gUfFbKHBatQN7qf2oifBBgBAgAJBQJQFHjTAhsMAAoJEA9Fky0/JEJtiw4D
    /3FKVj0fxlXcC5W1CFgYd+5SxxBLqaWRYNj9eT79FCvaTcQhYRqLkngV1vMQv5rz
    q3+5o/7RFdwsRryBXXm7a2hMC1EFtNdPb1hzXJSuv0r5kjXGj6NbdBbbCD+ByOMp
    r70ylDm30JYkXZNbtcGO7Alhmq0IDfTbR7rsmD+fsJmI
    =I+GJ
    -----END PGP PRIVATE KEY BLOCK-----
  EOS
end
