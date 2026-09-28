interface MomentPageProps {
  params: Promise<{ id: string }>;
}

export default async function MomentPage({ params }: MomentPageProps) {
  const { id } = await params;

  return (
    <main
      style={{
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "system-ui, -apple-system, sans-serif",
        padding: "2rem",
        textAlign: "center",
      }}
    >
      <h1 style={{ fontSize: "2rem", fontWeight: 700, marginBottom: "0.5rem" }}>
        Moment {id}
      </h1>
      <p style={{ color: "#888", fontSize: "1rem" }}>
        Share preview placeholder. Full playback experience arrives in Phase 11.
      </p>
    </main>
  );
}
