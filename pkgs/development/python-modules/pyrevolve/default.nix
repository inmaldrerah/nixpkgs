{ lib
, buildPythonPackage
, fetchFromGitHub
, contexttimer
, versioneer
, cython
, numpy
, pytest
, pythonOlder
}:

buildPythonPackage rec {
  pname = "pyrevolve";
  version = "2.2.3";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "devitocodes";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-z1G8DXG06Capd87x02zqrtYyBrX4xmJP94t4bgaR2PE=";
  };

  nativeBuildInputs = [
    versioneer
    cython
  ];

  propagatedBuildInputs = [
    contexttimer
    numpy
  ];

  nativeCheckInputs = [ pytest ];
  # Using approach bellow bcs the tests fail with the pytestCheckHook, throwing the following error
  # ImportError: cannot import name 'crevolve' from partially initialized module 'pyrevolve'
  # (most likely due to a circular import)
  checkPhase = ''
    pytest
  '';

  pythonImportsCheck = [
    "pyrevolve"
  ];

  meta = with lib; {
    homepage = "https://github.com/devitocodes/pyrevolve";
    changelog = "https://github.com/devitocodes/pyrevolve/releases/tag/v${version}";
    description = "Python library to manage checkpointing for adjoints";
    license = licenses.epl10;
    maintainers = with maintainers; [ atila ];
  };
}
