export default function HomePage() {
  return (
    <main
      style={{
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: "2rem",
        textAlign: "center",
        background: "radial-gradient(ellipse at 50% 30%, #1e1b4b 0%, #09090b 70%)",
        color: "#fafafa",
      }}
    >
      <div
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: "0.5rem",
          padding: "0.35rem 0.85rem",
          borderRadius: "9999px",
          background: "rgba(99, 102, 241, 0.15)",
          border: "1px solid rgba(99, 102, 241, 0.3)",
          color: "#a5b4fc",
          fontSize: "0.875rem",
          fontWeight: 500,
          marginBottom: "1.5rem",
        }}
      >
        <span
          style={{
            width: "8px",
            height: "8px",
            borderRadius: "50%",
            background: "#6366f1",
            boxShadow: "0 0 10px #6366f1",
          }}
        />
        Mobile App & Share Web Platform
      </div>

      <h1
        style={{
          fontSize: "clamp(2.5rem, 6vw, 4.5rem)",
          fontWeight: 800,
          letterSpacing: "-0.03em",
          lineHeight: 1.1,
          marginBottom: "1rem",
          background: "linear-gradient(180deg, #ffffff 0%, #a1a1aa 100%)",
          WebkitBackgroundClip: "text",
          WebkitTextFillColor: "transparent",
        }}
      >
        Moments: coming soon
      </h1>

      <p
        style={{
          maxWidth: "520px",
          fontSize: "1.125rem",
          lineHeight: 1.6,
          color: "#a1a1aa",
          marginBottom: "2rem",
        }}
      >
        Save exact song moments from YouTube, organize them into seamless groups,
        and share with deep links.
      </p>

      <div
        style={{
          display: "flex",
          gap: "1rem",
          alignItems: "center",
          fontSize: "0.875rem",
          color: "#71717a",
        }}
      >
        <span>Phase 0: Foundation</span>
        <span>•</span>
        <span>Flutter + Supabase + Next.js</span>
      </div>
    </main>
  );
}
