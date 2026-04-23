import { handleCors, jsonCorsHeaders } from "../_shared/cors.ts";

type Departure = {
  destination: string;
  line: string;
  minutesUntilDeparture: number;
  platform: string;
};

function getAllowedWebOrigins(): string[] {
  return (Deno.env.get("ALLOWED_WEB_ORIGINS") ?? "")
    .split(",")
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
}

function getEnvOrThrow(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`${name} is not configured`);
  }
  return value;
}

function toMinutes(iso: string): number {
  const date = new Date(iso);
  const diffMs = date.getTime() - Date.now();
  const minutes = Math.floor(diffMs / 60000);
  return minutes < 0 ? 0 : minutes;
}

Deno.serve(async (req) => {
  const allowedOrigins = getAllowedWebOrigins();
  const cors = handleCors(req, { allowedOrigins });
  if (cors) {
    return cors;
  }

  try {
    const apiKey = getEnvOrThrow("TFNSW_API_KEY");
    const stopId = Deno.env.get("TFNSW_STOP_ID") ?? "10101403";
    const endpoint =
      `https://api.transport.nsw.gov.au/v1/tp/departure_mon?outputFormat=rapidJSON&type_dm=stop&name_dm=${stopId}&mode=direct&depArrMacro=dep&TfNSWDM=true&version=10.2.1.42`;

    const upstream = await fetch(endpoint, {
      headers: {
        Authorization: `apikey $apiKey`,
      },
      signal: AbortSignal.timeout(10000),
    });
    if (!upstream.ok) {
      return new Response(JSON.stringify([]), {
        headers: {
          ...jsonCorsHeaders(req, { allowedOrigins }),
          "Content-Type": "application/json",
        },
      });
    }

    const payload = await upstream.json() as {
      departures?: Array<{
        platform?: {
          name?: string;
          direction?: {
            name?: string;
            line?: {
              transportation?: {
                number?: string;
              };
            };
          };
          stop?: {
            parent?: {
              departures?: string;
            };
          };
        };
        stop?: {
          parent?: {
            departures?: string;
          };
        };
        when?: string;
      }>;
    };

    const departures: Departure[] = (payload.departures ?? [])
      .map((item) => {
        const when =
          item.when ??
          item.stop?.parent?.departures ??
          item.platform?.stop?.parent?.departures;
        return {
          destination: item.platform?.direction?.name ?? "",
          line: item.platform?.direction?.line?.transportation?.number ?? "",
          minutesUntilDeparture: when == null ? 0 : toMinutes(when),
          platform: item.platform?.name ?? "",
        };
      })
      .filter((item) => item.destination.isNotEmpty)
      .sort((a, b) => a.minutesUntilDeparture - b.minutesUntilDeparture)
      .slice(0, 3);

    return new Response(JSON.stringify(departures), {
      headers: {
        ...jsonCorsHeaders(req, { allowedOrigins }),
        "Content-Type": "application/json",
      },
    });
  } catch (_error) {
    return new Response(JSON.stringify([]), {
      headers: {
        ...jsonCorsHeaders(req, { allowedOrigins }),
        "Content-Type": "application/json",
      },
      status: 200,
    });
  }
});
