{ stdenv, fetchurl, bash, which, coreutils,
  libuuid, attr, kmod,
  zlib, openssl, 
  kernel ? null 
} :

let
  version = "6.14";
in
  stdenv.mkDerivation { 
    name = "beegfs-module-${version}-${kernel.version}";

    src = fetchurl {
      url = "https://git.beegfs.com/pub/v6/repository/archive.tar.bz2?ref=${version}";
      sha256 = "0nr4rz24w5qrq019rm3m1p530qicah22lkl8glkrxcwg5lwp92hs";
    };

    hardeningDisable = [ "fortify" "pic" "stackprotector" ];

    nativeBuildInputs = [ which bash kmod ];
    buildInputs = [ libuuid attr zlib openssl  ];
    postPatch = ''
      find -type f -executable -exec sed -i "s:/bin/bash:/usr/bin/env bash:" \{} \;
      find -type f -name Makefile -exec sed -i "s:/bin/bash:${bash}/bin/bash:" \{} \;
      find -type f -name Makefile -exec sed -i "s:/bin/true:${coreutils}/bin/true:" \{} \;
      find -type f -name "*.mk" -exec sed -i "s:/bin/true:${coreutils}/bin/true:" \{} \;
    '';


    buildPhase = ''
      cd beegfs_client_module/build
      export KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build/
      make 
    '';

    installPhase = ''
      instdir=$out/lib/modules/${kernel.modDirVersion}/extras/fs/beegfs
      mkdir -p $instdir
      cp beegfs.ko $instdir
    '';

    meta = {
      description = "High performance distributed filesystem";
      homepage = "https://www.beegfs.io";
    };
  }


