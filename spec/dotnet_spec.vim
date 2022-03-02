source spec/support/helpers.vim

function! s:remove_path(cmd)
  return substitute(a:cmd, '\/.*\/spec\/fixtures\/dotnet\/', '', '')
endfunction

describe "DotnetTest"

  before
    cd spec/fixtures/dotnet
  end

  after
    call Teardown()
    cd -
  end

  it "runs nearest tests for file namespace"
    view +6 FileNamespaceTests.cs
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName=Namespace.Tests.TestAsyncWithTaskReturn'
  end

  it "runs nearest tests"
    view +3 Tests.cs
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName~Namespace.Tests'

    view +8 Tests.cs
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName=Namespace.Tests.TestAsync'

    view +14 Tests.cs
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName=Namespace.Tests.Test'

    view +20 Tests.cs
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName=Namespace.Tests.TestAsyncWithTaskReturn'
  end

  it "runs file test if nearest test couldn't be found"
    view +2 Tests.cs
    normal O
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName~Namespace'
  end

  it "runs test suites"
    view Tests.cs
    TestSuite

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj'
  end

  it "runs nearest test for nested tests"
    view NestedTests.cs
    view +10
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName=Namespace.Parent+NestedTests.TestAsync'

    view +16
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName=Namespace.Parent+NestedTests.Test'

    view +24
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName=Namespace.Parent+NestedTests+DeeplyNestedTests.TestAsync'
  end

  it "runs tests for parent class for nested tests"
    view NestedTests.cs
    view +5
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName~Namespace.Parent+NestedTests'
  end

  it "runs tests for file with nested tests if nearest test couldn't found"
    view +2 NestedTests.cs
    normal O
    TestNearest

    let actual = s:remove_path(g:test#last_command)
    Expect actual == 'dotnet test Tests.csproj --filter FullyQualifiedName~Namespace'
  end
end
