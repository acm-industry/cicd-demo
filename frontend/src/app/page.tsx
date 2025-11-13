import Body from "@/components/Body";
import Header from "@/components/Header";

export default function Home() {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        minHeight: "100vh",
      }}
    >
      <Header />
      <Body />
      <Header />
    </div>
  );
}
