class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "file://localhost/Users/mvogelgesang/Develop/homebrew-quick-org-creator/tmp-quick-org-creator.tar.gz"
  # LOCAL sha256 "0b821e301329f35bfcbec8fc25d88b26ec9fde165c046cbc5dfe619d921d7599"
  version File.read("VERSION").strip
  url "https://github.com/mvogelgesang/homebrew-quick-org-creator/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "9c4aca9f857c36143e6dad8d8b1834b2cf7f9c4db3e1acb352adfd4f8ba97967"
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
