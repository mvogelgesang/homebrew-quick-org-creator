# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class QuickOrgCreator < Formula
  desc "A script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  url "https://github.com/mvogelgesang/homebrew-quick-org-creator/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "3b1d62ac4b8e27bc2858fb7f2b83e8776f54ee3cca360d66244be87be1f10727"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    bin.install "src/run.sh" => "oc"
  end

  test do
    system "#{bin}/oc", "namespace"
  end
end
