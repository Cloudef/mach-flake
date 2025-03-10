{
  zigHook,
  zigBin,
  zigSrc,
}:

let
  bin = release: zigBin { inherit zigHook release; };
  src = release: zigSrc { inherit zigHook release; };

  meta-latest = {
    version = "latest";
    zigVersion = "0.14.0-dev.2577+271452d22";
    date = "2024-12-30";
    docs = "https://ziglang.org/documentation/master/";
    stdDocs = "https://ziglang.org/documentation/master/std/";
    machDocs = "https://machengine.org/docs/nominated-zig";
    machNominated = "2024-12-30";

    src = {
      tarball = "https://pkg.machengine.org/zig/zig-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "a979e021e3be89f45eccf6d081032da03afc674db753ab400ad8c85b7ee3c089";
      size = 17415084;
    };

    bootstrap = {
      tarball = "https://pkg.machengine.org/zig/zig-bootstrap-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "e89811ad94fc63b4b65314d03cee4313e04e9db2eb38d6b95cfc262f054461be";
      size = 47683004;
    };

    x86_64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-x86_64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "19e0b3673fd16609f7ce504faadb1c988270c2ed7cb250a7a9cb74beb22a4c23";
      size = 50641584;
    };

    aarch64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-aarch64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "034d395256d9f8b9f4e9fb07bc3428336b5138853dc2d518898fa0fa8fab434f";
      size = 45544344;
    };

    x86_64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86_64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "7be6abdebfa970c6138d165b348d0464e84f16f531e71cb20c0e052fae1d8c8d";
      size = 48706328;
    };

    aarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-aarch64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "cafbc9b83e624d8e7e55c41991c2c8d33b52d25661d94c27f236fb622ce168e4";
      size = 44578188;
    };

    armv7l-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-armv7a-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "ce4a447027be85577f7a739a09345931572dd69f9dc68d5b53d1cf667bfaf664";
      size = 45783832;
    };

    riscv64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-riscv64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "99ee8d18a6f9a513f203a2d8e0024edd8fee710b9ae267ba238bbb98cedbb754";
      size = 47684988;
    };

    powerpc64le-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc64le-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "1404f4b51b861883145b4757f94c46e9656b0c6b9e00ccd7e8499df691a32974";
      size = 48376852;
    };

    i686-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "f9a4f54b3f014a704793725e79f9ed377b87af681a8a947804d14d2bf954eb82";
      size = 51273288;
    };

    loongarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-loongarch64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "b70062294fb49e857f5bba0154c08966973080766af12e1b68dbfab743f0550d";
      size = 45450020;
    };

    x86_64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86_64-0.14.0-dev.2577+271452d22.zip";
      shasum = "23f0c4a4f789b6e1a82861bc14ea80652ba1d75784fcca55e74d50be24cf60e9";
      size = 83182005;
    };

    aarch64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-aarch64-0.14.0-dev.2577+271452d22.zip";
      shasum = "3563af9bf14a8e510c02c7858320db712348557b71a7d9844d8a960363207518";
      size = 79117742;
    };

    i686-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86-0.14.0-dev.2577+271452d22.zip";
      shasum = "f51180c3423093cf5f908686c4c0db8f091fafe22debfa1ffbcdf0260e713ece";
      size = 84906339;
    };
  };

  meta-2024_11_0 = {
    version = "2024.11.0";
    zigVersion = "0.14.0-dev.2577+271452d22";
    date = "2024-12-30";
    docs = "https://ziglang.org/documentation/master/";
    stdDocs = "https://ziglang.org/documentation/master/std/";
    machDocs = "https://machengine.org/docs/nominated-zig";
    machNominated = "2024-12-30";

    src = {
      tarball = "https://pkg.machengine.org/zig/zig-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "a979e021e3be89f45eccf6d081032da03afc674db753ab400ad8c85b7ee3c089";
      size = 17415084;
    };

    bootstrap = {
      tarball = "https://pkg.machengine.org/zig/zig-bootstrap-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "e89811ad94fc63b4b65314d03cee4313e04e9db2eb38d6b95cfc262f054461be";
      size = 47683004;
    };

    x86_64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-x86_64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "19e0b3673fd16609f7ce504faadb1c988270c2ed7cb250a7a9cb74beb22a4c23";
      size = 50641584;
    };

    aarch64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-aarch64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "034d395256d9f8b9f4e9fb07bc3428336b5138853dc2d518898fa0fa8fab434f";
      size = 45544344;
    };

    x86_64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86_64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "7be6abdebfa970c6138d165b348d0464e84f16f531e71cb20c0e052fae1d8c8d";
      size = 48706328;
    };

    aarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-aarch64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "cafbc9b83e624d8e7e55c41991c2c8d33b52d25661d94c27f236fb622ce168e4";
      size = 44578188;
    };

    armv7l-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-armv7a-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "ce4a447027be85577f7a739a09345931572dd69f9dc68d5b53d1cf667bfaf664";
      size = 45783832;
    };

    riscv64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-riscv64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "99ee8d18a6f9a513f203a2d8e0024edd8fee710b9ae267ba238bbb98cedbb754";
      size = 47684988;
    };

    powerpc64le-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc64le-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "1404f4b51b861883145b4757f94c46e9656b0c6b9e00ccd7e8499df691a32974";
      size = 48376852;
    };

    i686-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "f9a4f54b3f014a704793725e79f9ed377b87af681a8a947804d14d2bf954eb82";
      size = 51273288;
    };

    loongarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-loongarch64-0.14.0-dev.2577+271452d22.tar.xz";
      shasum = "b70062294fb49e857f5bba0154c08966973080766af12e1b68dbfab743f0550d";
      size = 45450020;
    };

    x86_64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86_64-0.14.0-dev.2577+271452d22.zip";
      shasum = "23f0c4a4f789b6e1a82861bc14ea80652ba1d75784fcca55e74d50be24cf60e9";
      size = 83182005;
    };

    aarch64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-aarch64-0.14.0-dev.2577+271452d22.zip";
      shasum = "3563af9bf14a8e510c02c7858320db712348557b71a7d9844d8a960363207518";
      size = 79117742;
    };

    i686-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86-0.14.0-dev.2577+271452d22.zip";
      shasum = "f51180c3423093cf5f908686c4c0db8f091fafe22debfa1ffbcdf0260e713ece";
      size = 84906339;
    };
  };

  meta-2024_10_0 = {
    version = "2024.10.0";
    zigVersion = "0.14.0-dev.1911+3bf89f55c";
    date = "2024-10-14";
    docs = "https://ziglang.org/documentation/master/";
    stdDocs = "https://ziglang.org/documentation/master/std/";
    machDocs = "https://machengine.org/docs/nominated-zig";
    machNominated = "2024-10-14";

    src = {
      tarball = "https://pkg.machengine.org/zig/zig-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "53b40ced023a41631014931c1141d9d4245ce41b674c46c34beceb2ba24ba9f9";
      size = 17611756;
    };

    bootstrap = {
      tarball = "https://pkg.machengine.org/zig/zig-bootstrap-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "213284ce3259ac6ebd085f6f3d4e3d25dc855de2d39975d3c094fbfde2662a21";
      size = 47879500;
    };

    x86_64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-x86_64-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "07dab7e71d61465bebed305d2c8bfae53c5f3b9422dd8e481f1b04bf3812c54b";
      size = 50747736;
    };

    aarch64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-aarch64-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "fde79992e2f60d8a9155cf0d177c7c84db2a5729f716419660fc75f5d1ed2a95";
      size = 46759892;
    };

    x86_64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86_64-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "73347307b8fcc4d5aab92b7c39f41740ae7b8ee2a82912aecb8cbbf7b6f899fd";
      size = 48853352;
    };

    aarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-aarch64-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "d37e7c596b0bb86e3160eb0f25c8951d7f31ed78dd3f127c701fa9ff95b49298";
      size = 44868320;
    };

    armv7l-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-armv7a-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "ceacc87fd821a252fe15c34b4ab0539deea001b7f83837ff468126f743e1752c";
      size = 45885272;
    };

    riscv64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-riscv64-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "9cde06923f402ad564cbb6fcedf07d011fa810525cdb40a6bec8cbb3f4151be4";
      size = 47458608;
    };

    powerpc64le-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc64le-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "7cb2d169d4849f556582751a62ca2f77e38c86a1798a805e3586e1062deafcd1";
      size = 48400260;
    };

    i686-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "d8b7587cab34b25191f77c769557f174fe6f140c4b6ff230a41606b912cdc60f";
      size = 54107716;
    };

    loongarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-loongarch64-0.14.0-dev.1911+3bf89f55c.tar.xz";
      shasum = "e7fb9c63895d2ec536dc0f7bf16ca3d71e4daff8a5d9e7fb629fc4092015c295";
      size = 45260020;
    };

    x86_64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86_64-0.14.0-dev.1911+3bf89f55c.zip";
      shasum = "10141d62ecdc41784cf24912dbcdc4fbafd8cac7b3818c7fe3ea4d1ab9bccfc5";
      size = 82910190;
    };

    aarch64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-aarch64-0.14.0-dev.1911+3bf89f55c.zip";
      shasum = "9a600ae56d40782f174204f4715bf6f3eadf536146dc794bbbd9a662b2dae70b";
      size = 78930721;
    };

    i686-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86-0.14.0-dev.1911+3bf89f55c.zip";
      shasum = "65caad6ed7bb9e50cbc35e0c886fdd78b4cd325d97967d41fe76cafc1cc02ad8";
      size = 87169135;
    };
  };

  meta-0_4_0 = {
    version = "0.4.0";
    zigVersion = "0.13.0-dev.351+64ef45eb0";
    date = "2024-06-01";
    docs = "https://ziglang.org/documentation/master/";
    stdDocs = "https://ziglang.org/documentation/master/std/";
    machDocs = "https://machengine.org/docs/nominated-zig";
    machNominated = "2024-06-01";

    src = {
      tarball = "https://pkg.machengine.org/zig/zig-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "6db25e78eca948664d4b1b1eb6b5ca6c471e0bf32b8fd19cc7c925b4d957f097";
      size = 17199760;
    };

    bootstrap = {
      tarball = "https://pkg.machengine.org/zig/zig-bootstrap-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "ff545922a63807aa812dcabf37feb47d2641ab2d9f354bc03c610ee2bc69ac9e";
      size = 46433700;
    };

    x86_64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-x86_64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "7de18dfc05fc989629311727470f22af9e9e75cb52997c333938eef666e4396e";
      size = 48835880;
    };

    aarch64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-aarch64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "fef4c33cc8b2c9af1caf47df98786c6bc049dd70ec6c05c794a3273b2937801b";
      size = 44895124;
    };

    x86_64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86_64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "351bcaa1b43db30dc24fb7f34dc598fd7ee4d571f164a4e9bc6dac6f6e6e3c56";
      size = 47116964;
    };

    aarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-aarch64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "20b9602db87482a1b03ca61acaac6acc17e6e3dc2e46d3521430a6aac3e8c4ef";
      size = 43108620;
    };

    armv7l-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-armv7a-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "4c1dac2c4fc37e355da42fcab12b77b27ff3fecf1d238d1e4049e8e513a7c539";
      size = 44044840;
    };

    riscv64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-riscv64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "141e40bf24e783926b3d76510a1a87e8f875247d4fe877faf14f908fdd2ddeb9";
      size = 45564236;
    };

    powerpc64le-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc64le-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "03839298a9c98aeb9b56e98d7c589909b6c279178dffe714fd9a3c325718ec98";
      size = 46546392;
    };

    i686-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "85051749303503c0da45a8554283f71fce949372f203c6392138842040fe8ea7";
      size = 52054076;
    };

    x86_64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86_64-0.13.0-dev.351+64ef45eb0.zip";
      shasum = "7be394a9fa1e131ecd948cd0137a72fcde18afdca7c4420333057974dfee5b7d";
      size = 79621321;
    };

    aarch64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-aarch64-0.13.0-dev.351+64ef45eb0.zip";
      shasum = "d2b2d5a61258222467e0de8615675e2e66e184dc36c142adcf628246c97636a4";
      size = 75584259;
    };

    i686-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86-0.13.0-dev.351+64ef45eb0.zip";
      shasum = "f63946af192ddc40ec9ea7af8a7ed56119d19afc42d0106715e994a37d1cd96c";
      size = 83726392;
    };
  };

  meta-2024_5_0 = {
    version = "2024.5.0";
    zigVersion = "0.13.0-dev.351+64ef45eb0";
    date = "2024-06-01";
    docs = "https://ziglang.org/documentation/master/";
    stdDocs = "https://ziglang.org/documentation/master/std/";
    machDocs = "https://machengine.org/docs/nominated-zig";
    machNominated = "2024-06-01";

    src = {
      tarball = "https://pkg.machengine.org/zig/zig-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "6db25e78eca948664d4b1b1eb6b5ca6c471e0bf32b8fd19cc7c925b4d957f097";
      size = 17199760;
    };

    bootstrap = {
      tarball = "https://pkg.machengine.org/zig/zig-bootstrap-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "ff545922a63807aa812dcabf37feb47d2641ab2d9f354bc03c610ee2bc69ac9e";
      size = 46433700;
    };

    x86_64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-x86_64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "7de18dfc05fc989629311727470f22af9e9e75cb52997c333938eef666e4396e";
      size = 48835880;
    };

    aarch64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-aarch64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "fef4c33cc8b2c9af1caf47df98786c6bc049dd70ec6c05c794a3273b2937801b";
      size = 44895124;
    };

    x86_64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86_64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "351bcaa1b43db30dc24fb7f34dc598fd7ee4d571f164a4e9bc6dac6f6e6e3c56";
      size = 47116964;
    };

    aarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-aarch64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "20b9602db87482a1b03ca61acaac6acc17e6e3dc2e46d3521430a6aac3e8c4ef";
      size = 43108620;
    };

    armv7l-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-armv7a-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "4c1dac2c4fc37e355da42fcab12b77b27ff3fecf1d238d1e4049e8e513a7c539";
      size = 44044840;
    };

    riscv64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-riscv64-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "141e40bf24e783926b3d76510a1a87e8f875247d4fe877faf14f908fdd2ddeb9";
      size = 45564236;
    };

    powerpc64le-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc64le-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "03839298a9c98aeb9b56e98d7c589909b6c279178dffe714fd9a3c325718ec98";
      size = 46546392;
    };

    i686-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86-0.13.0-dev.351+64ef45eb0.tar.xz";
      shasum = "85051749303503c0da45a8554283f71fce949372f203c6392138842040fe8ea7";
      size = 52054076;
    };

    x86_64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86_64-0.13.0-dev.351+64ef45eb0.zip";
      shasum = "7be394a9fa1e131ecd948cd0137a72fcde18afdca7c4420333057974dfee5b7d";
      size = 79621321;
    };

    aarch64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-aarch64-0.13.0-dev.351+64ef45eb0.zip";
      shasum = "d2b2d5a61258222467e0de8615675e2e66e184dc36c142adcf628246c97636a4";
      size = 75584259;
    };

    i686-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86-0.13.0-dev.351+64ef45eb0.zip";
      shasum = "f63946af192ddc40ec9ea7af8a7ed56119d19afc42d0106715e994a37d1cd96c";
      size = 83726392;
    };
  };

  meta-2024_3_0 = {
    version = "2024.3.0";
    zigVersion = "0.12.0-dev.3180+83e578a18";
    date = "2024-03-08";
    docs = "https://ziglang.org/documentation/master/";
    stdDocs = "https://ziglang.org/documentation/master/std/";
    machDocs = "https://machengine.org/docs/nominated-zig";
    machNominated = "2024-03-08";

    src = {
      tarball = "https://pkg.machengine.org/zig/zig-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "f484f26899b872782f37603b633236abaca4005e26d544fcbdfa1eb0f2503217";
      size = 17006740;
    };

    bootstrap = {
      tarball = "https://pkg.machengine.org/zig/zig-bootstrap-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "9291c11044e2658fc945240d6c0ae1f809228a6bcf456be592009010b8e3456f";
      size = 45451536;
    };

    x86_64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-x86_64-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "3d2fe9d76e0bc72430d142cde671fc4f99919aad451d3582121b2746abb5791f";
      size = 50374996;
    };

    aarch64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-aarch64-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "c3d455129203fc5ebab77bf9ab4580f15a60f7d5a4a856ef9a1dc80aae856c02";
      size = 46655260;
    };

    x86_64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86_64-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "66dd365aee3569e71940eb6fb2d47466f04b5ecb430aee74b9624b42ce17d6f6";
      size = 48671208;
    };

    aarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-aarch64-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "6b4f85c6f5bdc0a9e05ef7d1f49d437c36d8a63d30dba152c83740c0547e38e4";
      size = 45082920;
    };

    armv7l-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-armv7a-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "35ed38c07acb8f03729dde067662b05cbeee529b6d105ca11b204c25323e13c1";
      size = 45827420;
    };

    riscv64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-riscv64-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "1f81ed5e2d11a80d42cbc7b1b17b2b7f12b7a4cf14b439462fdc2eead3d0d199";
      size = 47151216;
    };

    powerpc64le-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc64le-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "29fb7a64797c939cada9db5740d2efdb3225425ca258e8cbb331135c31460d4b";
      size = 48481048;
    };

    i686-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86-0.12.0-dev.3180+83e578a18.tar.xz";
      shasum = "c687559a1f810b1d252f45d980d6396755c4ff7e509836332fff9f62a9fc79fa";
      size = 53685856;
    };

    x86_64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86_64-0.12.0-dev.3180+83e578a18.zip";
      shasum = "471acf6a4ea582720664159b0a2df8b32f1029d6681f80b7354cbb3c3d84b1e8";
      size = 82811850;
    };

    aarch64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-aarch64-0.12.0-dev.3180+83e578a18.zip";
      shasum = "e48fd79741afff7567394ca53a90d75c8a4b6d36c7c76e701ec172a303db4b5e";
      size = 79451816;
    };

    i686-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86-0.12.0-dev.3180+83e578a18.zip";
      shasum = "40a429e933218590d12615bb1e5ca961ffbc5719e061d6e9d3893c043e559d6f";
      size = 87426453;
    };
  };

  meta-0_3_0 = {
    version = "0.3.0";
    zigVersion = "0.12.0-dev.2063+804cee3b9";
    date = "2024-01-07";
    docs = "https://ziglang.org/documentation/master/";
    stdDocs = "https://ziglang.org/documentation/master/std/";
    machDocs = "https://machengine.org/docs/nominated-zig";
    machNominated = "2024-01-07";

    src = {
      tarball = "https://pkg.machengine.org/zig/zig-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "9838d42d47b7b8a0a38e87049830e528f5a6eaf5f2ccda40177dd8e2c293af78";
      size = 15989148;
    };

    bootstrap = {
      tarball = "https://pkg.machengine.org/zig/zig-bootstrap-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "56867d20e287285a62552d2e3547b62c34b680192bb4ae2472faa1a910ba7b14";
      size = 44431944;
    };

    x86_64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-x86_64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "1d40ebfec0e72db3fa666e9a997841fd96a704e3b1fc84391dfd7366bf443899";
      size = 49454960;
    };

    aarch64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-aarch64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "46d0fe89a0357b9f54ea5b15526db04926a9209b871b6d0abd4c7da1cc65acee";
      size = 45908952;
    };

    x86_64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86_64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "4c450d5817da7914b27be2147f9740ebdf186cc933ae87ddb2a8eaa130d02d57";
      size = 47204444;
    };

    aarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-aarch64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "98957f7dce0331cd8e605a703ee29432ef2f8a5117da5e4ed3b1a80923c46fe3";
      size = 43545248;
    };

    armv7l-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-armv7a-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "213673b0ba8b3e3c0323eb6a1fd33fe8dca9c7a66b5b0f3908dd0f41b365ddff";
      size = 44295524;
    };

    riscv64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-riscv64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "8573478f89c3de971e6ed69eb6defee473ae7197aefeec3ed77bb04918789a6b";
      size = 45538828;
    };

    powerpc64le-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc64le-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "8e12deafb740dab817e3c7b3cc7ab99192d7036bc759684f6fcdb28c85fb7f24";
      size = 46905304;
    };

    powerpc-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "92821ba18a3720df6f91ee54642e65dbdf62b1fb03380a0c89e4eb581671776c";
      size = 46634964;
    };

    i686-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "b437eaf626190bb6d2cf4a0eab91ec2850461aec809f681445183a15808697b3";
      size = 52236508;
    };

    x86_64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86_64-0.12.0-dev.2063+804cee3b9.zip";
      shasum = "8dc5ecd7a0871d1d024e50fffdb51f0aef96c7023d9a935c598610a51f3c725c";
      size = 79920855;
    };

    aarch64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-aarch64-0.12.0-dev.2063+804cee3b9.zip";
      shasum = "299d5455cbb4a2370a6675a79f32b01956ffbdda8d70bb78e8a1671940ecd971";
      size = 76499584;
    };

    i686-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86-0.12.0-dev.2063+804cee3b9.zip";
      shasum = "cab356caec718b6237e83d4c84bc278d06e84bda76c13d4aed2c211ab204de3b";
      size = 84448695;
    };
  };

  meta-2024_1_0 = {
    version = "2024.1.0";
    zigVersion = "0.12.0-dev.2063+804cee3b9";
    date = "2024-01-07";
    docs = "https://ziglang.org/documentation/master/";
    stdDocs = "https://ziglang.org/documentation/master/std/";
    machDocs = "https://machengine.org/docs/nominated-zig";
    machNominated = "2024-01-07";

    src = {
      tarball = "https://pkg.machengine.org/zig/zig-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "9838d42d47b7b8a0a38e87049830e528f5a6eaf5f2ccda40177dd8e2c293af78";
      size = 15989148;
    };

    bootstrap = {
      tarball = "https://pkg.machengine.org/zig/zig-bootstrap-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "56867d20e287285a62552d2e3547b62c34b680192bb4ae2472faa1a910ba7b14";
      size = 44431944;
    };

    x86_64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-x86_64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "1d40ebfec0e72db3fa666e9a997841fd96a704e3b1fc84391dfd7366bf443899";
      size = 49454960;
    };

    aarch64-darwin = {
      tarball = "https://pkg.machengine.org/zig/zig-macos-aarch64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "46d0fe89a0357b9f54ea5b15526db04926a9209b871b6d0abd4c7da1cc65acee";
      size = 45908952;
    };

    x86_64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86_64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "4c450d5817da7914b27be2147f9740ebdf186cc933ae87ddb2a8eaa130d02d57";
      size = 47204444;
    };

    aarch64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-aarch64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "98957f7dce0331cd8e605a703ee29432ef2f8a5117da5e4ed3b1a80923c46fe3";
      size = 43545248;
    };

    armv7l-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-armv7a-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "213673b0ba8b3e3c0323eb6a1fd33fe8dca9c7a66b5b0f3908dd0f41b365ddff";
      size = 44295524;
    };

    riscv64-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-riscv64-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "8573478f89c3de971e6ed69eb6defee473ae7197aefeec3ed77bb04918789a6b";
      size = 45538828;
    };

    powerpc64le-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc64le-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "8e12deafb740dab817e3c7b3cc7ab99192d7036bc759684f6fcdb28c85fb7f24";
      size = 46905304;
    };

    powerpc-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-powerpc-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "92821ba18a3720df6f91ee54642e65dbdf62b1fb03380a0c89e4eb581671776c";
      size = 46634964;
    };

    i686-linux = {
      tarball = "https://pkg.machengine.org/zig/zig-linux-x86-0.12.0-dev.2063+804cee3b9.tar.xz";
      shasum = "b437eaf626190bb6d2cf4a0eab91ec2850461aec809f681445183a15808697b3";
      size = 52236508;
    };

    x86_64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86_64-0.12.0-dev.2063+804cee3b9.zip";
      shasum = "8dc5ecd7a0871d1d024e50fffdb51f0aef96c7023d9a935c598610a51f3c725c";
      size = 79920855;
    };

    aarch64-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-aarch64-0.12.0-dev.2063+804cee3b9.zip";
      shasum = "299d5455cbb4a2370a6675a79f32b01956ffbdda8d70bb78e8a1671940ecd971";
      size = 76499584;
    };

    i686-mingw32 = {
      tarball = "https://pkg.machengine.org/zig/zig-windows-x86-0.12.0-dev.2063+804cee3b9.zip";
      shasum = "cab356caec718b6237e83d4c84bc278d06e84bda76c13d4aed2c211ab204de3b";
      size = 84448695;
    };
  };
in
{
  latest = bin meta-latest;
  src-latest = src meta-latest;
  "2024_11_0" = bin meta-2024_11_0;
  src-2024_11_0 = src meta-2024_11_0;
  "2024_10_0" = bin meta-2024_10_0;
  src-2024_10_0 = src meta-2024_10_0;
  "0_4_0" = bin meta-0_4_0;
  src-0_4_0 = src meta-0_4_0;
  "2024_5_0" = bin meta-2024_5_0;
  src-2024_5_0 = src meta-2024_5_0;
  "2024_3_0" = bin meta-2024_3_0;
  src-2024_3_0 = src meta-2024_3_0;
  "0_3_0" = bin meta-0_3_0;
  src-0_3_0 = src meta-0_3_0;
  "2024_1_0" = bin meta-2024_1_0;
  src-2024_1_0 = src meta-2024_1_0;
}
