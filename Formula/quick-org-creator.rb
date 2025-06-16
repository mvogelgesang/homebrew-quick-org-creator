class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.3.8.tar.gz"
  # LOCAL sha256 "47365389dd18828f173d0b9f54737da938df9b7617e4f70184fc62727a55edfe"
  version File.read("VERSION").strip
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.3.8.tar.gz"
  sha256 "47365389dd18828f173d0b9f54737da938df9b7617e4f70184fc62727a55edfe"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    libexec.install Dir["src/*"]
    libexec.install Dir["fileTemplates/"]
    libexec.install Dir["..scratchDefs/"]
    libexec.install "VERSION"
    bin.install_symlink libexec/"run.sh" => "oc"
  end

  test do
    system "#{bin}/oc", "namespace"
  end
end
