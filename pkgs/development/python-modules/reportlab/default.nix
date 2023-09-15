{ lib
, buildPythonPackage
, fetchPypi
, freetype
, pillow
, glibcLocales
, python
, isPyPy
}:

let
  ft = freetype.overrideAttrs (oldArgs: { dontDisableStatic = true; });
in buildPythonPackage rec {
  pname = "reportlab";
  version = "4.0.4";
  format = "pyproject";

  # See https://bitbucket.org/pypy/compatibility/wiki/reportlab%20toolkit
  disabled = isPyPy;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-f3CztWr/XxHLQTbFGg9aVv5uTI+7rHuQMHbbmajvMcE=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "mif = findFile(d,'ft2build.h')" "mif = findFile('${lib.getDev ft}','ft2build.h')"

    # Remove all the test files that require access to the internet to pass.
    rm tests/test_lib_utils.py
    rm tests/test_platypus_general.py
    rm tests/test_platypus_images.py

    # Remove the tests that require Vera fonts installed
    rm tests/test_graphics_render.py
    rm tests/test_graphics_charts.py
  '';

  buildInputs = [
    ft
  ];

  propagatedBuildInputs = [
    pillow
  ];

  nativeCheckInputs = [
    glibcLocales
  ];

  checkPhase = ''
    runHook preCheck
    pushd tests
    LC_ALL="en_US.UTF-8" ${python.interpreter} runAll.py
    popd
    runHook postCheck
  '';

  meta = with lib; {
    description = "An Open Source Python library for generating PDFs and graphics";
    homepage = "http://www.reportlab.com/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
