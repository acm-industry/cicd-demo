import type { CSSProperties } from "react";

const headerStyle: CSSProperties = {
  backgroundColor: "hsla(0, 0%, 0%, 0.62)",
  color: "white",
  padding: "1.5rem 1rem",
  boxShadow: "0px 4px 6px rgba(0,0,0,0.1)",
  position: "fixed",
  width: "100vw",
  zIndex: 10,
};

const containerStyle: CSSProperties = {
  maxWidth: "1200px",
  margin: "0 auto",
  padding: "0 1rem",
};

const titleStyle: CSSProperties = {
  fontWeight: "bold",
  marginTop: "0.5rem",
  color: "white",
};

export default function Header() {
  return (
    <footer style={headerStyle}>
      <div style={{...containerStyle, display: "flex", alignItems: "center", gap: "1rem"}}>
        <img
          src="/industry_nav_logo.png"
          alt="Logo"
          style={{ height: "40px" }}
        />
        <h1 style={{...titleStyle, marginTop: "0"}}>Demo Website</h1>
      </div>
    </footer>
  );
}

